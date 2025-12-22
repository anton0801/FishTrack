import SwiftUI

struct CatchDetailsView: View {
    let catchItem: Catch
    @Binding var catches: [Catch]
    @State private var showingEdit = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Fish: \(catchItem.fishType)")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("Weight: \(catchItem.weight, specifier: "%.2f") kg")
                        .foregroundColor(.white)
                    if let length = catchItem.length {
                        Text("Length: \(length, specifier: "%.2f") cm")
                            .foregroundColor(.white)
                    }
                    Text("Location: \(catchItem.location)")
                        .foregroundColor(.white)
                    Text("Date: \(catchItem.date, style: .date)")
                        .foregroundColor(.white)
                    Text("Notes: \(catchItem.notes)")
                        .foregroundColor(.white)
                }
                .padding()
            }
            .navigationTitle("Catch Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit") {
                            showingEdit = true
                        }
                        Button("Delete", role: .destructive) {
                            if let index = catches.firstIndex(where: { $0.id == catchItem.id }) {
                                catches.remove(at: index)
                            }
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingEdit) {
                EditCatchView(catchItem: catchItem, catches: $catches)
            }
        }
    }
}
