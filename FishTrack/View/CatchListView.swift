import Foundation
import SwiftUI


struct CatchListView: View {
    @Binding var catches: [Catch]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            List {
                ForEach(catches) { catchItem in
                    HStack {
                        Image(systemName: "fish.fill")
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading) {
                            Text(catchItem.fishType)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(catchItem.weight, specifier: "%.2f") kg")
                                .foregroundColor(.white.opacity(0.8))
                            Text(catchItem.date, style: .date)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .onDelete { indices in
                    catches.remove(atOffsets: indices)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Catch List")
        }
    }
}
