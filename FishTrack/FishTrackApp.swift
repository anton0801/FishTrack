import SwiftUI
import Combine
import Firebase
import UserNotifications
import AppsFlyerLib
import AppTrackingTransparency

struct AppConstants {
    static let appsFlyerAppID = "6756781385"
    static let appsFlyerDevKey = "Jxqe682BgXxvunZwuRMN77"
}

@main
struct FishTrackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                SplashView()
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct CheckPermissionPromptUseCase {
    let repo: TrackRepository
    
    func perform() -> Bool {
        guard !repo.retrievePermissionsAccepted(),
              !repo.retrievePermissionsDenied() else {
            return false
        }
        if let previous = repo.retrieveLastPermissionRequest(),
           Date().timeIntervalSince(previous) < 259200 {
            return false
        }
        return true
    }
}

struct ActivateLegacyUseCase {
    let repo: TrackRepository
    
    func perform() {
        repo.updateAppState("Inactive")
        repo.markAsRun()
    }
}

struct RetrieveCachedTrackUseCase {
    let repo: TrackRepository
    
    func perform() -> URL? {
        repo.retrieveStoredTrack()
    }
}

struct CacheSuccessfulTrackUseCase {
    let repo: TrackRepository
    
    func perform(track: String) {
        repo.storeTrack(track)
        repo.updateAppState("FishView")
        repo.markAsRun()
    }
}

struct ProcessSkipPermissionsUseCase {
    let repo: TrackRepository
    
    func perform() {
        repo.updateLastPermissionRequest(Date())
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, AppsFlyerLibDelegate, MessagingDelegate, UNUserNotificationCenterDelegate, DeepLinkDelegate {
    
    private var conversionData: [AnyHashable: Any] = [:]
    private var deeplinkData: [AnyHashable: Any] = [:]
    private var mergeTimer: Timer?
    private let trackingSentKey = "trackingDataSent"
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    @objc private func startTracking() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                }
            }
        }
    }
    
    func application(_ app: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupFirebase()
        setupDelegates()
        registerForNotifications()
        handleLaunchNotifications(launchOptions: launchOptions)
        configureAppsFlyer()
        addObservers()
        return true
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func setupDelegates() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func registerForNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func handleLaunchNotifications(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if let notificationInfo = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            parseNotification(notificationInfo)
        }
    }
    
    private func configureAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = AppConstants.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = AppConstants.appsFlyerAppID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().deepLinkDelegate = self
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startTracking),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        parseNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status,
              let deeplinkObject = result.deepLink else { return }
        guard !UserDefaults.standard.bool(forKey: trackingSentKey) else { return }
        
        deeplinkData = deeplinkObject.clickEvent
        NotificationCenter.default.post(name: Notification.Name("deeplink_values"), object: nil, userInfo: ["deeplinksData": deeplinkData])
        mergeTimer?.invalidate()
        
        if !conversionData.isEmpty {
            sendMergedData()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        parseNotification(userInfo)
        completionHandler(.newData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { [weak self] token, error in
            guard error == nil, let activeToken = token else { return }
            self?.updateToken(activeToken)
        }
    }
    
    private func updateToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "fcm_token")
        UserDefaults.standard.set(token, forKey: "push_token")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let infoPayload = notification.request.content.userInfo
        parseNotification(infoPayload)
        completionHandler([.banner, .sound])
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        conversionData = data
        startMergeTimer()
        if !deeplinkData.isEmpty {
            sendMergedData()
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        sendData(data: [:])
    }
}

extension AppDelegate {
    
    private func startMergeTimer() {
        mergeTimer?.invalidate()
        mergeTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.sendMergedData()
        }
    }
    
    private func parseNotification(_ info: [AnyHashable: Any]) {
        let extractor = FishPushExtractor()
        if let urlString = extractor.extract(info: info) {
            UserDefaults.standard.set(urlString, forKey: "temp_url")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("LoadTempURL"),
                    object: nil,
                    userInfo: ["temp_url": urlString]
                )
            }
        }
    }
    
    private func sendData(data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: Notification.Name("ConversionDataReceived"),
            object: nil,
            userInfo: ["conversionData": data]
        )
    }
    
    private func sendMergedData() {
        var mergedData = conversionData
        for (key, value) in deeplinkData {
            if mergedData[key] == nil {
                mergedData[key] = value
            }
        }
        sendData(data: mergedData)
        UserDefaults.standard.set(true, forKey: trackingSentKey)
    }
}

struct FishPushExtractor {
    func extract(info: [AnyHashable: Any]) -> String? {
        var parsedLink: String?
        if let link = info["url"] as? String {
            parsedLink = link
        } else if let subInfo = info["data"] as? [String: Any],
                  let subLink = subInfo["url"] as? String {
            parsedLink = subLink
        }
        if let activeLink = parsedLink {
            return activeLink
        }
        return nil
    }
}
