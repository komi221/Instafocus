import SwiftUI
import WebKit

struct DMWebView: UIViewRepresentable {
    static let home = URL(string: "https://www.instagram.com/direct/inbox/")!

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()          // 로그인 유지
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = .all
        config.userContentController.addUserScript(
            WKUserScript(source: FilterScript.source,
                         injectionTime: .atDocumentEnd,
                         forMainFrameOnly: true))
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.uiDelegate = context.coordinator
        wv.allowsBackForwardNavigationGestures = true
        wv.isOpaque = false
        wv.backgroundColor = .black
        wv.scrollView.backgroundColor = .black
        wv.load(URLRequest(url: Self.home))
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        // DM 관련 경로만 허용 (피드/릴스/탐색 등은 차단)
        private let allowedPaths = ["/direct", "/accounts", "/challenge", "/auth_platform",
                                    "/oauth", "/api", "/web", "/login", "/two_factor", "/consent"]

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
            if navigationAction.targetFrame?.isMainFrame == false { decisionHandler(.allow); return }

            let scheme = url.scheme ?? ""
            if !["http", "https"].contains(scheme) { decisionHandler(.allow); return }  // about/blob/data

            let host = url.host ?? ""
            let isIG = host == "instagram.com" || host.hasSuffix(".instagram.com")
            let isFB = host == "facebook.com" || host.hasSuffix(".facebook.com")

            if isFB { decisionHandler(.allow); return }
            if isIG {
                let p = url.path
                if p.isEmpty || p == "/" {
                    decisionHandler(.cancel)
                    webView.load(URLRequest(url: DMWebView.home))
                } else if allowedPaths.contains(where: { p.hasPrefix($0) }) {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)   // 릴스/게시물/프로필 등
                }
                return
            }
            decisionHandler(.cancel)
            UIApplication.shared.open(url)      // 외부 링크는 Safari로
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url,
               !(url.host ?? "").hasSuffix("instagram.com") {
                UIApplication.shared.open(url)
            }
            return nil
        }

        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in completionHandler(false) })
            a.addAction(UIAlertAction(title: "확인", style: .default) { _ in completionHandler(true) })
            UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
                .first?.present(a, animated: true)
        }
    }
}
