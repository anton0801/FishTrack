import SwiftUI
import WebKit
import Combine

struct FishTypesView: View {
    @Binding var catches: [Catch]
    
    var fishTypes: [String: Int] {
        Dictionary(grouping: catches, by: { $0.fishType }).mapValues { $0.count }
    }
    
    var sortedFishTypes: [(key: String, value: Int)] {
        fishTypes.sorted(by: { $0.value > $1.value })
    }
    
    @State var fishType = ""
    @State var showList = false
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            List {
                ForEach(sortedFishTypes, id: \.key) { type, count in
                    Button {
                        fishType = type
                        showList
                    } label: {
                        HStack {
                            Text(type)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(count)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]), startPoint: .leading, endPoint: .trailing))
                        }
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.cyan, lineWidth: 1))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Fish Types")
        }
        .sheet(isPresented: $showList) {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                    .ignoresSafeArea()
                
                List {
                    ForEach(catches.filter { $0.fishType == fishType }) { catchItem in
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
}

class FishContentManager: ObservableObject {
    @Published var primaryView: WKWebView!
    
    private var subscriptions = Set<AnyCancellable>()
    
    func initializePrimaryView() {
        let config = createWebConfiguration()
        primaryView = WKWebView(frame: .zero, configuration: config)
        setupViewProperties(for: primaryView)
    }
    
    private func createWebConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let webpagePrefs = WKWebpagePreferences()
        webpagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webpagePrefs
        
        return config
    }
    
    private func setupViewProperties(for view: WKWebView) {
        view.scrollView.minimumZoomScale = 1.0
        view.scrollView.maximumZoomScale = 1.0
        view.scrollView.bounces = false
        view.scrollView.bouncesZoom = false
        view.allowsBackForwardNavigationGestures = true
    }
    
    @Published var secondaryViews: [WKWebView] = []
    
    func loadStoredCookies() {
        guard let cookieData = UserDefaults.standard.object(forKey: "preserved_grains") as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else { return }
        
        let cookieStore = primaryView.configuration.websiteDataStore.httpCookieStore
        let cookies = cookieData.values.flatMap { $0.values }.compactMap {
            HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any])
        }
        
        cookies.forEach { cookieStore.setCookie($0) }
    }
    
    func goBack(to url: URL? = nil) {
        if !secondaryViews.isEmpty {
            if let lastView = secondaryViews.last {
                lastView.removeFromSuperview()
                secondaryViews.removeLast()
            }
            
            if let targetURL = url {
                primaryView.load(URLRequest(url: targetURL))
            }
        } else if primaryView.canGoBack {
            primaryView.goBack()
        }
    }
    
    func reloadContent() {
        primaryView.reload()
    }
}
