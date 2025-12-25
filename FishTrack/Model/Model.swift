
import Foundation

struct Catch: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var fishType: String
    var weight: Double
    var length: Double?
    var location: String
    var notes: String
        
    init(id: UUID = UUID(), date: Date = Date(), fishType: String = "", weight: Double = 0.0, length: Double? = nil, location: String = "", notes: String = "") {
        self.id = id
        self.date = date
        self.fishType = fishType
        self.weight = weight
        self.length = length
        self.location = location
        self.notes = notes
    }
    
    static func == (lhs: Catch, rhs: Catch) -> Bool {
        return lhs.id == rhs.id
    }
}

// Model for Notes
struct Note: Identifiable, Codable {
    let id: UUID
    var text: String
    
    init(id: UUID = UUID(), text: String = "") {
        self.id = id
        self.text = text
    }
}


protocol TrackRepository {
    var isInitialRun: Bool { get }
    func retrieveStoredTrack() -> URL?
    func storeTrack(_ url: String)
    func updateAppState(_ state: String)
    func markAsRun()
    func retrieveAppState() -> String?
    func updateLastPermissionRequest(_ date: Date)
    func updatePermissionsAccepted(_ accepted: Bool)
    func updatePermissionsDenied(_ denied: Bool)
    func retrievePermissionsAccepted() -> Bool
    func retrievePermissionsDenied() -> Bool
    func retrieveLastPermissionRequest() -> Date?
    func retrievePushToken() -> String?
    func retrieveLanguageCode() -> String
    func retrieveAppIdentifier() -> String
    func retrieveFirebaseID() -> String?
    func retrieveAppStoreID() -> String
    func retrieveTrackingID() -> String
    func retrieveOrganicData(linkData: [String: Any]) async throws -> [String: Any]
    func retrieveServerTrack(data: [String: Any]) async throws -> URL
}
