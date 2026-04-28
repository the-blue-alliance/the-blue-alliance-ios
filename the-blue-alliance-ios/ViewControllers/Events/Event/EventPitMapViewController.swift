import TBAAPI
import UIKit
import WebKit

final class EventPitMapViewController: UIViewController, Navigatable {

    let dependencies: Dependencies
    private let url: URL

    var additionalRightBarButtonItems: [UIBarButtonItem] { [] }

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        return webView
    }()

    init(url: URL, title: String, dependencies: Dependencies) {
        self.url = url
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        webView.load(URLRequest(url: url))
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
