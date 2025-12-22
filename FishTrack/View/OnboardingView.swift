import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showDashboard = false
    
    let pages = [
        OnboardingPage(title: "Record Your Catches", description: "Keep track of every fish you catch.", icon: "fish.fill"),
        OnboardingPage(title: "Note Fish and Weight", description: "Log details like type, weight, and more.", icon: "scale.mass.fill"),
        OnboardingPage(title: "Analyze Your Fishing", description: "View stats and improve your skills.", icon: "chart.bar.fill")
    ]
    
    var body: some View {
        if showDashboard {
            DashboardView()
        } else {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6), Color.green.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        pages[index]
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                VStack {
                    Spacer()
                    HStack {
                        Button("Skip") {
                            showDashboard = true
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        if currentPage < pages.count - 1 {
                            Button("Next") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                            .foregroundColor(.yellow)
                        } else {
                            Button("Start") {
                                showDashboard = true
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let icon: String
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.yellow)
            Text(title)
                .font(.title)
                .foregroundColor(.white)
                .padding()
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}
