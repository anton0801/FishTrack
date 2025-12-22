import SwiftUI

struct DashboardView: View {
    @State private var catches: [Catch] = UserDefaults.standard.loadCatches()
    
    var totalCatches: Int {
        catches.count
    }
    
    var biggestFish: String {
        if let maxCatch = catches.max(by: { $0.weight < $1.weight }) {
            return "\(maxCatch.fishType) - \(maxCatch.weight) kg"
        }
        return "None yet"
    }
    
    var lastFishingDay: String {
        if let lastCatch = catches.max(by: { $0.date < $1.date }) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: lastCatch.date)
        }
        return "None yet"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: "fish.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.yellow)
                        Text("Fish Track")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    // Dashboard cards
                    ScrollView {
                        VStack(spacing: 20) {
                            DashboardCard(title: "Total Catches", value: "\(totalCatches)", icon: "fish.circle.fill")
                            DashboardCard(title: "Biggest Fish", value: biggestFish, icon: "waveform.path.ecg")
                            DashboardCard(title: "Last Fishing Day", value: lastFishingDay, icon: "calendar.circle.fill")
                        }
                        .padding()
                    }
                    
                    // Add Catch button
                    NavigationLink(destination: AddCatchView(catches: $catches)) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text("Add Catch")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.blue)
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 20) {
                        NavigationLink(destination: CatchListView(catches: $catches)) {
                            Image(systemName: "list.bullet.circle.fill")
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: FishTypesView(catches: $catches)) {
                            Image(systemName: "fish.circle.fill")
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: LocationsView(catches: $catches)) {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.white)
                        }
//                        NavigationLink(destination: CalendarView(catches: $catches)) {
//                            Image(systemName: "calendar.circle.fill")
//                                .foregroundColor(.white)
//                        }
                        NavigationLink(destination: StatisticsView(catches: $catches)) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: NotesView()) {
                            Image(systemName: "note.text")
                                .foregroundColor(.white)
                        }
                        NavigationLink(destination: SettingsView(catches: $catches)) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onChange(of: catches) { newCatches in
                UserDefaults.standard.saveCatches(newCatches)
            }
        }
        .accentColor(.yellow)
    }
}

struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.yellow)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.3))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
}
