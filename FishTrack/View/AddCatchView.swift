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
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                
                TextField("Fish Type", text: $fishType)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                
                TextField("Weight (kg)", text: $weight)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                
                TextField("Length (cm, optional)", text: $length)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                
                TextField("Location", text: $location)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
                
                TextField("Notes", text: $notes)
                    .foregroundStyle(.white)
                    .listRowBackground(Color.black.opacity(0.5))
            }
            .scrollContentBackground(.hidden)
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
                    .font(.headline)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing))
                }
            }
        }
    }
}
