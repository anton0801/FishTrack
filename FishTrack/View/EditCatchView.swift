import SwiftUI

struct EditCatchView: View {
    let catchItem: Catch
    @Binding var catches: [Catch]
    @Environment(\.dismiss) var dismiss
    
    @State private var date: Date
    @State private var fishType: String
    @State private var weight: String
    @State private var length: String
    @State private var location: String
    @State private var notes: String
    
    init(catchItem: Catch, catches: Binding<[Catch]>) {
        self.catchItem = catchItem
        self._catches = catches
        self._date = State(initialValue: catchItem.date)
        self._fishType = State(initialValue: catchItem.fishType)
        self._weight = State(initialValue: String(catchItem.weight))
        self._length = State(initialValue: catchItem.length != nil ? String(catchItem.length!) : "")
        self._location = State(initialValue: catchItem.location)
        self._notes = State(initialValue: catchItem.notes)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Fish Type", text: $fishType)
                TextField("Weight (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                TextField("Length (cm, optional)", text: $length)
                    .keyboardType(.decimalPad)
                TextField("Location", text: $location)
                TextField("Notes", text: $notes)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit Catch")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let weightDouble = Double(weight), !fishType.isEmpty {
                            let lengthDouble = Double(length)
                            if let index = catches.firstIndex(where: { $0.id == catchItem.id }) {
                                catches[index] = Catch(id: catchItem.id, date: date, fishType: fishType, weight: weightDouble, length: lengthDouble, location: location, notes: notes)
                            }
                            dismiss()
                        }
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
    }
}
