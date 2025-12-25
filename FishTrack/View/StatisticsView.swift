import SwiftUI
import Charts

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
    
    // Data for charts
    var monthlyCatches: [ (month: String, count: Int) ] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: catches) { catchItem in
            let components = calendar.dateComponents([.year, .month], from: catchItem.date)
            return "\(components.year!)-\(components.month!)"
        }
        return grouped.map { (month: $0.key, count: $0.value.count) }.sorted(by: { $0.month < $1.month })
    }
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    StatCard(title: "Total Weight", value: "\(totalWeight.format()) kg")
                    StatCard(title: "Average Weight", value: "\(averageWeight.format()) kg")
                    StatCard(title: "Biggest Catch", value: biggestCatch)
                    StatCard(title: "Most Common Fish", value: mostCommonFish)
                    
                    if !monthlyCatches.isEmpty {
                        Chart {
                            ForEach(monthlyCatches, id: \.month) { data in
                                BarMark(
                                    x: .value("Month", data.month),
                                    y: .value("Catches", data.count)
                                )
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple]), startPoint: .bottom, endPoint: .top))
                            }
                        }
                        .frame(height: 300)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .purple.opacity(0.6), radius: 15)
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
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
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
        .shadow(color: .orange.opacity(0.6), radius: 15)
    }
}

extension Double {
    func format(d: Int = 2) -> String {
        return String(format: "%.\(d)f", self)
    }
}
