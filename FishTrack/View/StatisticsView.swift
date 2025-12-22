import SwiftUI

struct StatisticsView: View {
    @Binding var catches: [Catch]
    
    var totalWeight: Double {
        catches.reduce(0) { $0 + $1.weight }
    }
    
    var averageWeight: Double {
        catches.isEmpty ? 0 : totalWeight / Double(catches.count)
    }
    
    var biggestCatch: String {
        if let maxCatch = catches.max(by: { $0.weight < $1.weight }) {
            return "\(maxCatch.fishType) - \(maxCatch.weight) kg"
        }
        return "None"
    }
    
    var mostCommonFish: String {
        let types = Dictionary(grouping: catches, by: { $0.fishType }).max(by: { $0.value.count < $1.value.count })?.key ?? "None"
        return types
    }
    
    // For graphs, we'd use Charts framework, but assuming iOS 16+, or simple text for now.
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    StatCard(title: "Total Weight", value: "\(totalWeight.format(digits: 2)) kg")
                    StatCard(title: "Average Weight", value: "\(averageWeight.format(digits: 2)) kg")
                    StatCard(title: "Biggest Catch", value: biggestCatch)
                    StatCard(title: "Most Common Fish", value: mostCommonFish)
                    // Add simple charts if needed, but omitted for brevity.
                }
                .padding()
            }
            .navigationTitle("Statistics")
        }
    }
}

extension Double {
    func format(digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(value)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.3))
        .cornerRadius(15)
    }
}
