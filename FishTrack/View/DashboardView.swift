import SwiftUI
import WebKit
import Combine

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
                RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "fish.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .top, endPoint: .bottom))
                            .shadow(color: .yellow, radius: 10)
                        Text("Fish Track")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.white, Color.cyan]), startPoint: .top, endPoint: .bottom))
                            .shadow(color: .cyan, radius: 15)
                    }
                    .padding(.top, 50)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            DashboardCard(title: "Total Catches", value: "\(totalCatches)", icon: "fish.circle.fill")
                            DashboardCard(title: "Biggest Fish", value: biggestFish, icon: "waveform.path.ecg")
                            DashboardCard(title: "Last Fishing Day", value: lastFishingDay, icon: "calendar.circle.fill")
                        }
                        .padding()
                    }
                    
                    NavigationLink(destination: AddCatchView(catches: $catches)) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("Add Catch")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(color: .orange.opacity(0.8), radius: 15)
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: 1.0)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 25) {
                            NavigationLink(destination: CatchListView(catches: $catches, location: "")) {
                                IconButton(icon: "list.bullet.circle.fill")
                            }
                            NavigationLink(destination: FishTypesView(catches: $catches)) {
                                IconButton(icon: "fish.circle.fill")
                            }
                            NavigationLink(destination: LocationsView(catches: $catches)) {
                                IconButton(icon: "location.circle.fill")
                            }
//                            NavigationLink(destination: CalendarView(catches: $catches)) {
//                                IconButton(icon: "calendar.circle.fill")
//                            }
                            NavigationLink(destination: StatisticsView(catches: $catches)) {
                                IconButton(icon: "chart.bar.fill")
                            }
                            NavigationLink(destination: NotesView()) {
                                IconButton(icon: "note.text")
                            }
                            NavigationLink(destination: SettingsView(catches: $catches)) {
                                IconButton(icon: "gearshape.fill")
                            }
                        }
                        .padding(.horizontal)
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

struct FishTrackMainView: View {
    
    @State private var currentContentURL: String? = ""
    
    var body: some View {
        ZStack {
            if let currentContentURL = currentContentURL {
                if let contentURL = URL(string: currentContentURL) {
                    FishContentHostView(contentURL: contentURL)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: initializeContentURL)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in
            loadTemporaryURL()
        }
    }
    
    private func initializeContentURL() {
        let tempURL = UserDefaults.standard.string(forKey: "temp_url")
        let storedURL = UserDefaults.standard.string(forKey: "stored_path") ?? ""
        currentContentURL = tempURL ?? storedURL
        
        if tempURL != nil {
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
    
    private func loadTemporaryURL() {
        if let tempURL = UserDefaults.standard.string(forKey: "temp_url"), !tempURL.isEmpty {
            currentContentURL = nil
            currentContentURL = tempURL
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
}

struct IconButton: View {
    let icon: String
    
    var body: some View {
        Image(systemName: icon)
            .resizable()
            .frame(width: 30, height: 30)
            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple]), startPoint: .top, endPoint: .bottom))
            .shadow(color: .cyan, radius: 5)
    }
}

struct DashboardCard: View {
    let title: String
    let value: String
    let icon: String
    @State private var hover = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .top, endPoint: .bottom))
                .shadow(color: .yellow, radius: 10)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(20)
        .background(Color.black.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
        .shadow(color: .purple.opacity(0.6), radius: 15)
        .scaleEffect(hover ? 1.05 : 1.0)
        .animation(.spring(), value: hover)
        .onTapGesture {
            hover.toggle()
        }
    }
}

#Preview {
    DashboardView()
}




