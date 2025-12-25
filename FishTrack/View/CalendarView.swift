import SwiftUI

struct CalendarView: View {
    @Binding var catches: [Catch]
    @State private var selectedDate = Date()
    
    var datesWithCatches: [Date] {
        catches.map { Calendar.current.startOfDay(for: $0.date) }
    }
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            VStack {
                DatePicker("Calendar", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .accentColor(.yellow)
                    .background(Color.black.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .cyan, radius: 15)
                    .padding()
                
//                if datesWithCatches.contains(Calendar.current.startOfDay(for: selectedDate)) {
//                    NavigationLink(destination: CatchListView(catches: .constant(catches.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }))) {
//                        Text("View Catches for \(selectedDate, style: .date)")
//                            .font(.headline)
//                            .padding()
//                            .background(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing))
//                            .foregroundColor(.blue)
//                            .clipShape(RoundedRectangle(cornerRadius: 20))
//                            .shadow(color: .orange.opacity(0.8), radius: 10)
//                    }
//                }
            }
            .navigationTitle("Calendar")
        }
    }
}
