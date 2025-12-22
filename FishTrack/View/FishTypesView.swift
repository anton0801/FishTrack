import SwiftUI

struct FishTypesView: View {
    @Binding var catches: [Catch]
    
    var fishTypes: [String: Int] {
        Dictionary(grouping: catches, by: { $0.fishType }).mapValues { $0.count }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            List {
                ForEach(fishTypes.sorted(by: { $0.value > $1.value }), id: \.key) { type, count in
                    NavigationLink(destination: CatchListView(catches: .constant(catches.filter { $0.fishType == type }))) {
                        HStack {
                            Text(type)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(count)")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Fish Types")
        }
    }
}
