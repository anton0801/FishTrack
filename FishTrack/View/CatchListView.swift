import Foundation
import SwiftUI

struct CatchListView: View {
    @Binding var catches: [Catch]
    var location: String
    
    var sortedCatches: [Catch] {
        catches.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            List {
                ForEach(sortedCatches.filter { location.isEmpty ? true : $0.location == location }) { catchItem in
                    NavigationLink(destination: CatchDetailsView(catchItem: catchItem, catches: $catches)) {
                        HStack {
                            Image(systemName: "fish.fill")
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .top, endPoint: .bottom))
                                .font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text(catchItem.fishType)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("\(catchItem.weight, specifier: "%.2f") kg")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                Text(catchItem.date, style: .date)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.cyan, lineWidth: 1))
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
