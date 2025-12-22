import Foundation
import SwiftUI

struct AddCatchView: View {
    @Binding var catches: [Catch]
    @Environment(\.dismiss) var dismiss
    
    @State private var date = Date()
    @State private var fishType = ""
    @State private var weight = ""
    @State private var length = ""
    @State private var location = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                Form {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .foregroundColor(.white)
                    
                    TextField("Fish Type", text: $fishType)
                        .foregroundColor(.white)
                    
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                    
                    TextField("Length (cm, optional)", text: $length)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.white)
                    
                    TextField("Location", text: $location)
                        .foregroundColor(.white)
                    
                    TextField("Notes", text: $notes)
                        .foregroundColor(.white)
                }
                .scrollContentBackground(.hidden) // Transparent form background
                .navigationTitle("Add Catch")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            if let weightDouble = Double(weight), !fishType.isEmpty {
                                let lengthDouble = Double(length)
                                let newCatch = Catch(date: date, fishType: fishType, weight: weightDouble, length: lengthDouble, location: location, notes: notes)
                                catches.append(newCatch)
                                dismiss()
                            }
                        }
                        .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}
