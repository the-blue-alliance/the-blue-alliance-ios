import PureLayout
import TBAAPI
import UIKit
import WebKit

final class EventPitMapViewController: UIViewController, Navigatable, WKNavigationDelegate {

    let dependencies: Dependencies
    private let url: URL
    private let focusTeamKey: String?
    private let focusLabelKey: String?

    var additionalRightBarButtonItems: [UIBarButtonItem] { [] }

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        webView.navigationDelegate = self
        return webView
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    init(
        url: URL,
        title: String,
        focusTeamKey: String? = nil,
        focusLabelKey: String? = nil,
        dependencies: Dependencies
    ) {
        self.url = url
        self.focusTeamKey = focusTeamKey
        self.focusLabelKey = focusLabelKey
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(spinner)
        view.addSubview(webView)
        webView.autoPinEdge(toSuperviewSafeArea: .top)
        webView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        spinner.autoCenterInSuperview()
        webView.alpha = 0
        spinner.startAnimating()
        webView.load(URLRequest(url: url))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let selector: String? = {
            if let focusTeamKey { return "[data-team-key=\"\(focusTeamKey)\"]" }
            if let focusLabelKey { return "[data-label-key=\"\(focusLabelKey)\"]" }
            return nil
        }()
        guard let selector else {
            spinner.stopAnimating()
            UIView.animate(withDuration: 0.15) { webView.alpha = 1 }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self, weak webView] in
            guard let self, let webView else { return }
            self.scrollToFocused(webView: webView, selector: selector)
        }
    }

    private func scrollToFocused(webView: WKWebView, selector: String) {
        let js = """
            (() => {
              const el = document.querySelector('\(selector)');
              if (!el) return null;
              const rect = el.getBoundingClientRect();
              return [
                rect.left + window.scrollX + rect.width / 2,
                rect.top + window.scrollY + rect.height / 2,
              ];
            })();
            """
        webView.evaluateJavaScript(js) { [weak self, weak webView] result, _ in
            guard let webView else { return }
            defer {
                self?.spinner.stopAnimating()
                UIView.animate(withDuration: 0.15) { webView.alpha = 1 }
            }
            guard let coords = result as? [Double], coords.count == 2 else { return }
            let zoom = webView.scrollView.zoomScale
            let bounds = webView.bounds
            let contentSize = webView.scrollView.contentSize
            let target = CGPoint(
                x: max(
                    0,
                    min(
                        coords[0] * zoom - bounds.width / 2,
                        max(0, contentSize.width - bounds.width)
                    )
                ),
                y: max(
                    0,
                    min(
                        coords[1] * zoom - bounds.height / 2,
                        max(0, contentSize.height - bounds.height)
                    )
                )
            )
            webView.scrollView.setContentOffset(target, animated: false)
        }
    }
}

enum EventPitMapURL {
    static func url(eventKey: EventKey, highlightTeamKeys: [String] = []) -> URL? {
        var components = URLComponents(
            string: "https://www.thebluealliance.com/event/\(eventKey)/pitmap"
        )
        if !highlightTeamKeys.isEmpty {
            components?.queryItems = [
                URLQueryItem(name: "teams", value: highlightTeamKeys.joined(separator: ","))
            ]
        }
        return components?.url
    }
}
