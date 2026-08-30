import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var urlString: String
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        // تعطيل النوافذ المنبثقة الإعلانية
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let currentURL = uiView.url?.absoluteString, currentURL != urlString {
            if let url = URL(string: urlString) {
                uiView.load(URLRequest(url: url))
            }
        }
        
        // تطبيق ثيم الموقع (داكن/فاتح) بالتزامن مع التطبيق
        let jsTheme = isDarkMode 
            ? "document.documentElement.classList.add('dark'); document.body.style.backgroundColor = '#000000'; document.body.style.color = '#ffffff';"
            : "document.documentElement.classList.remove('dark'); document.body.style.backgroundColor = '#ffffff'; document.body.style.color = '#000000';"
        
        uiView.evaluateJavaScript(jsTheme, completionHandler: nil)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // منع إعلانات النوافذ المنبثقة والتحويلات الخبيثة
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
            if let url = webView.url?.absoluteString {
                UserDefaults.standard.set(url, forKey: "lastURL")
            }
            
            // سكريبت حظر الإعلانات والعناصر المزعجة
            let removeAdsScript = """
                var selectors = [
                    'iframe[src*="ads"]', 'iframe[src*="doubleclick"]', '.ad-box', '.adsbox',
                    'div[class*="ad-"]', 'div[id*="pop"]', 'a[href*="bet"]', '.popunder'
                ];
                selectors.forEach(function(selector) {
                    var elements = document.querySelectorAll(selector);
                    elements.forEach(function(el) { el.remove(); });
                });
                window.open = function() { return null; };
            """
            webView.evaluateJavaScript(removeAdsScript, completionHandler: nil)
        }
    }
}
