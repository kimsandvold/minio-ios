import UIKit
import Capacitor
import WebKit

class MinioBridgeViewController: CAPBridgeViewController, WKNavigationDelegate {

    private var hasShownOffline = false

    override func viewDidLoad() {
        super.viewDidLoad()
        webView?.navigationDelegate = self
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain,
           nsError.code == NSURLErrorNotConnectedToInternet ||
           nsError.code == NSURLErrorNetworkConnectionLost ||
           nsError.code == NSURLErrorCannotConnectToHost ||
           nsError.code == NSURLErrorDNSLookupFailed ||
           nsError.code == NSURLErrorTimedOut {
            showOfflinePage()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain,
           nsError.code == NSURLErrorNotConnectedToInternet ||
           nsError.code == NSURLErrorNetworkConnectionLost {
            showOfflinePage()
        }
    }

    private func showOfflinePage() {
        guard !hasShownOffline else { return }
        hasShownOffline = true

        guard let path = Bundle.main.path(forResource: "offline", ofType: "html") else { return }
        let url = URL(fileURLWithPath: path)

        DispatchQueue.main.async { [weak self] in
            self?.webView?.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
}
