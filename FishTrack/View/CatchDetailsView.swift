import SwiftUI

struct CatchDetailsView: View {
    let catchItem: Catch
    @Binding var catches: [Catch]
    @State private var showingEdit = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    DetailItem(label: "Fish", value: catchItem.fishType)
                    DetailItem(label: "Weight", value: "\(catchItem.weight.format()) kg")
                    if let length = catchItem.length {
                        DetailItem(label: "Length", value: "\(length.format()) cm")
                    }
                    DetailItem(label: "Location", value: catchItem.location)
                    DetailItem(label: "Date", value: catchItem.date.formatted(date: .long, time: .omitted))
                    DetailItem(label: "Notes", value: catchItem.notes)
                }
                .padding(30)
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
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .top, endPoint: .bottom))
                    }
                }
            }
            .sheet(isPresented: $showingEdit) {
                EditCatchView(catchItem: catchItem, catches: $catches)
            }
        }
    }
}

struct DetailItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple]), startPoint: .leading, endPoint: .trailing), lineWidth: 1))
        .shadow(color: .purple.opacity(0.5), radius: 10)
    }
}
