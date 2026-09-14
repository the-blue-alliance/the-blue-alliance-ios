import Foundation
import MyTBAKit
import TBAAPI
import UIKit
import PureLayout

typealias DataController = Alertable

class TBAViewController: UIViewController, DataController, Navigatable {

    let dependencies: Dependencies

    var api: any TBAAPIProtocol { dependencies.api }
    var myTBA: any MyTBAProtocol { dependencies.myTBA }
    var myTBAStores: MyTBAStores { dependencies.myTBAStores }
    var statusService: any StatusServiceProtocol { dependencies.statusService }
    var urlOpener: any URLOpener { dependencies.urlOpener }

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(forAutoLayout: ())
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.clear
        return scrollView
    }()

    // MARK: - Refreshable

    var currentRefreshTask: Task<Void, Never>?

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return []
    }

    // MARK: - Init

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.systemGroupedBackground
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()

        // Same backdrop as the table base: blue behind the transparent bar on screens that
        // sit directly under it, nothing inside a container.
        let barBackdrop = UIView(forAutoLayout: ())
        barBackdrop.backgroundColor = UIColor.navigationBarTintColor
        view.addSubview(barBackdrop)
        barBackdrop.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        NSLayoutConstraint.activate([
            barBackdrop.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        (self as? any Refreshable)?.updateRefreshOnAppear()
    }

    // TODO: https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/133
    func reloadData() {
        fatalError("Implement this downstream")
    }

}

extension Refreshable where Self: TBAViewController {

    var refreshControl: UIRefreshControl? {
        get {
            return scrollView.refreshControl
        }
        set {
            scrollView.refreshControl = newValue
        }
    }

    var refreshView: UIScrollView {
        return scrollView
    }

}
