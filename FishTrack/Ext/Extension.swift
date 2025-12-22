import Foundation

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
