import SwiftUI

@main
struct FishTrackApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView(showSplash: $showSplash)
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
