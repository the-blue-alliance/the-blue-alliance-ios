import Foundation
import UIKit
import CoreData

typealias DataController = Persistable & Alertable & Stateful

class TBAViewController: UIViewController, DataController {

    var persistentContainer: NSPersistentContainer
    var noDataViewController: NoDataViewController?

    var requestsArray: [URLSessionDataTask] = []

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(forAutoLayout: ())
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()

    // MARK: - Init

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        super.init(nibName: nil, bundle: nil)
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

    // TODO: https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/133
    func reloadViewAfterRefresh() {
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

    var requests: [URLSessionDataTask] {
        get {
            return requestsArray
        }
        set {
            requestsArray = newValue
        }
    }

    var refreshView: UIScrollView {
        return scrollView
    }

}
