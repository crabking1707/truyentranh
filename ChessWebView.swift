import SwiftUI
import WebKit

/// WebView mở Chess.com và tự chèn menu "Hiếu Gamer Chess AI" (chess_ai.js)
/// vào MỌI trang. Menu là nút tím nổi + bảng điều khiển đè lên bàn cờ.
struct ChessWebView: UIViewRepresentable {
    static let startURL = URL(string: "https://www.chess.com")!
    static let background = UIColor(red: 0.086, green: 0.082, blue: 0.071, alpha: 1)

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()               // giữ đăng nhập
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true  // cho nút "Bật PiP giữ luồng"
        config.mediaTypesRequiringUserActionForPlayback = []
        config.applicationNameForUserAgent = "Version/17.0 Mobile/15E148 Safari/604.1"

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        // Chèn script vào "page world" để đọc được chess-board.game như bookmarklet
        if let url = Bundle.main.url(forResource: "chess_ai", withExtension: "js"),
           let source = try? String(contentsOf: url, encoding: .utf8) {
            let script = WKUserScript(source: source,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true,
                                      in: .page)
            config.userContentController.addUserScript(script)
        }

        let web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = context.coordinator
        web.uiDelegate = context.coordinator
        web.allowsBackForwardNavigationGestures = true
        web.isOpaque = false
        web.backgroundColor = Self.background
        web.scrollView.backgroundColor = Self.background
        if #available(iOS 16.4, *) { web.isInspectable = true }

        web.load(URLRequest(url: Self.startURL))
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // MARK: - Delegate

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {

        private func isExternal(_ url: URL) -> Bool {
            let host = (url.host ?? "").lowercased()
            return url.scheme == "tg"
                || host == "t.me" || host.hasSuffix(".t.me")
                || host == "telegram.me" || host == "telegram.org"
        }

        // Link Telegram -> mở app Telegram
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url, isExternal(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        // target=_blank / window.open -> mở ngay trong cùng WebView
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                if isExternal(url) { UIApplication.shared.open(url) }
                else { webView.load(navigationAction.request) }
            }
            return nil
        }

        // WebView bị hệ thống tắt do thiếu RAM -> tải lại
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }

        // alert() / confirm() của trang
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
            present(alert, fallback: completionHandler)
        }

        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completionHandler(false) })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
            present(alert, fallback: { completionHandler(false) })
        }

        private func present(_ alert: UIAlertController, fallback: () -> Void) {
            guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
                  let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                fallback(); return
            }
            var top = root
            while let next = top.presentedViewController { top = next }
            top.present(alert, animated: true)
        }
    }
}
