
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
