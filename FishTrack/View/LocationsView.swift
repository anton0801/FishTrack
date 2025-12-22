
import SwiftUI

struct LocationsView: View {
    @Binding var catches: [Catch]
    @State private var searchText = ""
    
    var locations: [String: (count: Int, lastDate: Date?)] {
        var dict: [String: (count: Int, lastDate: Date?)] = [:]
        for catchItem in catches {
            if dict[catchItem.location] == nil {
                dict[catchItem.location] = (1, catchItem.date)
            } else {
                var (count, lastDate) = dict[catchItem.location]!
                count += 1
                if catchItem.date > lastDate! {
                    lastDate = catchItem.date
                }
                dict[catchItem.location] = (count, lastDate)
            }
        }
        return dict
    }
    
    var filteredLocations: [(key: String, value: (count: Int, lastDate: Date?))] {
        locations.sorted(by: { $0.value.count > $1.value.count }).filter { searchText.isEmpty || $0.key.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                TextField("Search Location", text: $searchText)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                List {
                    ForEach(filteredLocations, id: \.key) { location, data in
                        NavigationLink(destination: CatchListView(catches: .constant(catches.filter { $0.location == location }))) {
                            VStack(alignment: .leading) {
                                Text(location)
                                    .foregroundColor(.white)
                                Text("Catches: \(data.count)")
                                    .foregroundColor(.white.opacity(0.8))
                                if let lastDate = data.lastDate {
                                    Text("Last: \(lastDate, style: .date)")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Locations")
        }
    }
}
