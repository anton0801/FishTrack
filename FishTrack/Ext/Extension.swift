import Foundation
import AppsFlyerLib
import Firebase
import FirebaseMessaging

extension UserDefaults {
    func saveCatches(_ catches: [Catch]) {
        if let encoded = try? JSONEncoder().encode(catches) {
            set(encoded, forKey: "catches")
        }
    }
    
    func loadCatches() -> [Catch] {
        if let data = data(forKey: "catches"),
           let decoded = try? JSONDecoder().decode([Catch].self, from: data) {
            return decoded
        }
        return []
    }
    
    func saveNotes(_ notes: [Note]) {
        if let encoded = try? JSONEncoder().encode(notes) {
            set(encoded, forKey: "notes")
        }
    }
    
    func loadNotes() -> [Note] {
        if let data = data(forKey: "notes"),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            return decoded
        }
        return []
    }
    
    func saveSettings(units: String) {
        set(units, forKey: "units")
    }
    
    func loadSettings() -> String {
        return string(forKey: "units") ?? "kg"
    }
}


class TrackRepositoryImpl: TrackRepository {
    private let defaults: UserDefaults
    private let tracker: AppsFlyerLib
    
    init(defaults: UserDefaults = .standard, tracker: AppsFlyerLib = .shared()) {
        self.defaults = defaults
        self.tracker = tracker
    }
    
    var isInitialRun: Bool {
        !defaults.bool(forKey: "hasRunPreviously")
    }
    
    func retrieveStoredTrack() -> URL? {
        if let stored = defaults.string(forKey: "stored_path"),
           let url = URL(string: stored) {
            return url
        }
        return nil
    }
    
    func storeTrack(_ url: String) {
        defaults.set(url, forKey: "stored_path")
    }
    
    func updateAppState(_ state: String) {
        defaults.set(state, forKey: "app_state")
    }
    
    func markAsRun() {
        defaults.set(true, forKey: "hasRunPreviously")
    }
    
    func retrieveAppState() -> String? {
        defaults.string(forKey: "app_state")
    }
    
    func updateLastPermissionRequest(_ date: Date) {
        defaults.set(date, forKey: "last_perm_request")
    }
    
    func updatePermissionsAccepted(_ accepted: Bool) {
        defaults.set(accepted, forKey: "perms_accepted")
    }
    
    func updatePermissionsDenied(_ denied: Bool) {
        defaults.set(denied, forKey: "perms_denied")
    }
    
    func retrievePermissionsAccepted() -> Bool {
        defaults.bool(forKey: "perms_accepted")
    }
    
    func retrievePermissionsDenied() -> Bool {
        defaults.bool(forKey: "perms_denied")
    }
    
    func retrieveLastPermissionRequest() -> Date? {
        defaults.object(forKey: "last_perm_request") as? Date
    }
    
    func retrievePushToken() -> String? {
        defaults.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
    }
    
    func retrieveLanguageCode() -> String {
        Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
    }
    
    func retrieveAppIdentifier() -> String {
        "com.fishingcamptrac.FishTrack"
    }
    
    func retrieveFirebaseID() -> String? {
        FirebaseApp.app()?.options.gcmSenderID
    }
    
    func retrieveAppStoreID() -> String {
        "id\(AppConstants.appsFlyerAppID)"
    }
    
    func retrieveTrackingID() -> String {
        tracker.getAppsFlyerUID()
    }
    
    func retrieveOrganicData(linkData: [String: Any]) async throws -> [String: Any] {
        let url = buildTrackingURL()
        guard let url else {
            throw NSError(domain: "TrackingError", code: 0)
        }
        let (data, resp) = try await URLSession.shared.data(from: url)
        try validateResponse(resp: resp, data: data)
        guard let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "TrackingError", code: 1)
        }
        return mergeData(jsonData: jsonData, linkData: linkData)
    }
    
    private func buildTrackingURL() -> URL? {
        TrackingBuilder()
            .assignAppID(AppConstants.appsFlyerAppID)
            .assignDevKey(AppConstants.appsFlyerDevKey)
            .assignUID(retrieveTrackingID())
            .generate()
    }
    
    private func validateResponse(resp: URLResponse, data: Data) throws {
        guard let httpResp = resp as? HTTPURLResponse,
              httpResp.statusCode == 200 else {
            throw NSError(domain: "TrackingError", code: 1)
        }
    }
    
    private func mergeData(jsonData: [String: Any], linkData: [String: Any]) -> [String: Any] {
        var merged = jsonData
        for (k, v) in linkData where merged[k] == nil {
            merged[k] = v
        }
        return merged
    }
    
    func retrieveServerTrack(data: [String: Any]) async throws -> URL {
        let endpoint = try getEndpointURL()
        var requestData = prepareRequestData(baseData: data)
        let body = try serializeRequestData(requestData: requestData)
        let req = buildRequest(endpoint: endpoint, body: body)
        let (responseData, _) = try await URLSession.shared.data(for: req)
        return try parseResponseData(responseData: responseData)
    }
    
    private func getEndpointURL() throws -> URL {
        guard let url = URL(string: "https://fishtraack.com/config.php") else {
            throw NSError(domain: "TrackError", code: 0)
        }
        return url
    }
    
    private func prepareRequestData(baseData: [String: Any]) -> [String: Any] {
        var requestData = baseData
        requestData["os"] = "iOS"
        requestData["af_id"] = retrieveTrackingID()
        requestData["bundle_id"] = retrieveAppIdentifier()
        requestData["firebase_project_id"] = retrieveFirebaseID()
        requestData["store_id"] = retrieveAppStoreID()
        requestData["push_token"] = retrievePushToken()
        requestData["locale"] = retrieveLanguageCode()
        return requestData
    }
    
    private func serializeRequestData(requestData: [String: Any]) throws -> Data {
        guard let body = try? JSONSerialization.data(withJSONObject: requestData) else {
            throw NSError(domain: "TrackError", code: 1)
        }
        return body
    }
    
    private func buildRequest(endpoint: URL, body: Data) -> URLRequest {
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = body
        return req
    }
    
    private func parseResponseData(responseData: Data) throws -> URL {
        guard let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
              let success = json["ok"] as? Bool, success,
              let trackStr = json["url"] as? String,
              let trackURL = URL(string: trackStr) else {
            throw NSError(domain: "TrackError", code: 2)
        }
        return trackURL
    }
}
