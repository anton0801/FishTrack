import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showDashboard = false
    
    let pages = [
        OnboardingPage(title: "Record Your Catches", description: "Keep track of every fish you catch with futuristic precision.", icon: "fish.fill"),
        OnboardingPage(title: "Note Fish and Weight", description: "Log details like type, weight, and more in a neon glow.", icon: "scale.mass.fill"),
        OnboardingPage(title: "Analyze Your Fishing", description: "View stats and improve your skills with holographic insights.", icon: "chart.bar.fill")
    ]
    
    var body: some View {
        if showDashboard {
            DashboardView()
        } else {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
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
                            withAnimation(.spring()) {
                                showDashboard = true
                            }
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: .cyan, radius: 5)
                        
                        Spacer()
                        
                        if currentPage < pages.count - 1 {
                            Button("Next") {
                                withAnimation(.easeInOut) {
                                    currentPage += 1
                                }
                            }
                            .font(.headline)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                            .shadow(color: .yellow.opacity(0.8), radius: 10)
                        } else {
                            Button("Start") {
                                withAnimation(.spring()) {
                                    showDashboard = true
                                }
                            }
                            .font(.headline)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                            .shadow(color: .yellow.opacity(0.8), radius: 10)
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
                .frame(width: 120, height: 120)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.purple]), startPoint: .top, endPoint: .bottom))
                .shadow(color: .cyan, radius: 15)
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
            Text(description)
                .font(.system(size: 18, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: .purple.opacity(0.5), radius: 20)
    }
}

#Preview {
    OnboardingView()
}
