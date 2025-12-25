
import SwiftUI
import WebKit

struct LocationsView: View {
    @Binding var catches: [Catch]
    @State private var searchText = ""
    
    var locations: [String: (count: Int, lastDate: Date?)] {
        var dict: [String: (count: Int, lastDate: Date?)] = [:]
        for catchItem in catches {
            let key = catchItem.location
            if let existing = dict[key] {
                let newCount = existing.count + 1
                let newDate = max(existing.lastDate ?? catchItem.date, catchItem.date)
                dict[key] = (newCount, newDate)
            } else {
                dict[key] = (1, catchItem.date)
            }
        }
        return dict
    }
    
    var filteredLocations: [(key: String, value: (count: Int, lastDate: Date?))] {
        locations.sorted(by: { $0.value.count > $1.value.count }).filter { searchText.isEmpty || $0.key.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.cyan.opacity(0.7), Color.green.opacity(0.5), Color.purple.opacity(0.3)]), center: .center, startRadius: 0, endRadius: 800)
                .ignoresSafeArea()
            
            VStack {
                TextField("Search Location", text: $searchText)
                    .font(.system(size: 18, design: .rounded))
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.cyan, lineWidth: 1))
                    .padding(.horizontal)
                    .shadow(color: .cyan.opacity(0.5), radius: 5)
                
                List {
                    ForEach(filteredLocations, id: \.key) { location, data in
                        NavigationLink(destination: CatchListView(catches: $catches, location: location)) {
                            VStack(alignment: .leading) {
                                Text(location)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Catches: \(data.count)")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                if let lastDate = data.lastDate {
                                    Text("Last: \(lastDate, style: .date)")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.purple, lineWidth: 1))
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Locations")
        }
    }
}

class FishNavigationCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    private var redirectCount = 0
    
    init(manager: FishContentManager) {
        self.contentManager = manager
        super.init()
    }
    
    private var contentManager: FishContentManager
    
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        
        let newView = WKWebView(frame: .zero, configuration: configuration)
        configureNewView(newView)
        addConstraintsToNewView(newView)
        
        contentManager.secondaryViews.append(newView)
        
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(processEdgeSwipe))
        edgeGesture.edges = .left
        newView.addGestureRecognizer(edgeGesture)
        
        if isValidRequest(navigationAction.request) {
            newView.load(navigationAction.request)
        }
        
        return newView
    }
    
    private func isValidRequest(_ request: URLRequest) -> Bool {
        guard let urlString = request.url?.absoluteString,
              !urlString.isEmpty,
              urlString != "about:blank" else { return false }
        return true
    }
    
    private var lastURL: URL?
    
    private let redirectLimit = 70
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    private func configureNewView(_ webView: WKWebView) {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        contentManager.primaryView.addSubview(webView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let jsCode = """
        (function() {
            const meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.head.appendChild(meta);
            
            const style = document.createElement('style');
            style.textContent = 'body { touch-action: pan-x pan-y; } input, textarea { font-size: 16px !important; }';
            document.head.appendChild(style);
            
            document.addEventListener('gesturestart', e => e.preventDefault());
            document.addEventListener('gesturechange', e => e.preventDefault());
        })();
        """
        
        webView.evaluateJavaScript(jsCode) { _, error in
            if let error = error { print("JS injection error: \(error)") }
        }
    }
    
    @objc private func processEdgeSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .ended,
              let view = gesture.view as? WKWebView else { return }
        
        if view.canGoBack {
            view.goBack()
        } else if contentManager.secondaryViews.last === view {
            contentManager.goBack(to: nil)
        }
    }
    
    private func storeCookies(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            var cookieMap: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            
            for cookie in cookies {
                var domainDict = cookieMap[cookie.domain] ?? [:]
                if let properties = cookie.properties {
                    domainDict[cookie.name] = properties
                }
                cookieMap[cookie.domain] = domainDict
            }
            
            UserDefaults.standard.set(cookieMap, forKey: "preserved_grains")
        }
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        if (error as NSError).code == NSURLErrorHTTPTooManyRedirects,
           let fallbackURL = lastURL {
            webView.load(URLRequest(url: fallbackURL))
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        redirectCount += 1
        
        if redirectCount > redirectLimit {
            webView.stopLoading()
            if let fallbackURL = lastURL {
                webView.load(URLRequest(url: fallbackURL))
            }
            return
        }
        
        lastURL = webView.url
        storeCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        lastURL = url
        
        let scheme = (url.scheme ?? "").lowercased()
        let urlString = url.absoluteString.lowercased()
        
        let validSchemes: Set<String> = ["http", "https", "about", "blob", "data", "javascript", "file"]
        let validStarts = ["srcdoc", "about:blank", "about:srcdoc"]
        
        let isValid = validSchemes.contains(scheme) ||
                      validStarts.contains { urlString.hasPrefix($0) } ||
                      urlString == "about:blank"
        
        if isValid {
            decisionHandler(.allow)
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { _ in }
        
        decisionHandler(.cancel)
    }
    
    private func addConstraintsToNewView(_ webView: WKWebView) {
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: contentManager.primaryView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentManager.primaryView.trailingAnchor),
            webView.topAnchor.constraint(equalTo: contentManager.primaryView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: contentManager.primaryView.bottomAnchor)
        ])
    }
}
