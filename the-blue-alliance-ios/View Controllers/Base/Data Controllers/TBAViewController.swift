import Foundation
import UIKit
import CoreData

typealias DataController = Persistable & Refreshable & Alertable & Stateful

class TBAViewController: UIViewController, DataController {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(forAutoLayout: ())
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    // MARK: - Persistable

    var persistentContainer: NSPersistentContainer

    // MARK: - Refreshable

    var requests: [URLSessionDataTask] = []

    var refreshView: UIScrollView {
        return scrollView
    }

    var refreshControl: UIRefreshControl? = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()

    // MARK: - Stateful

    var noDataViewController: NoDataViewController?

    // MARK: - Init

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        super.init(nibName: nil, bundle: nil)

        enableRefreshing()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .backgroundGray
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()
    }

    @objc func refresh() {
        fatalError("Implement this downstream")
    }

    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }

    // TODO: https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/133
    func reloadViewAfterRefresh() {
        fatalError("Implement this downstream")
    }

    func enableRefreshing() {
        scrollView.refreshControl = refreshControl
    }

    func disableRefreshing() {
        scrollView.refreshControl = nil
    }

}
