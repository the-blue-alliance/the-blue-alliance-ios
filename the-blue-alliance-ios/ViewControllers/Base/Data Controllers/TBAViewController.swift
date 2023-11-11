import CoreData
import Foundation
import TBAKit
import TBAUtils
import UIKit

typealias DataController = Persistable & Alertable

class TBAViewController: UIViewController, DataController, Navigatable {

    private let dependencies: Dependencies

    var errorRecorder: ErrorRecorder {
        return dependencies.errorRecorder
    }
    var persistentContainer: NSPersistentContainer {
        return dependencies.persistentContainer
    }
    var tbaKit: TBAKit {
        return dependencies.tbaKit
    }
    var userDefaults: UserDefaults {
        return dependencies.userDefaults
    }

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView(forAutoLayout: ())
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.clear
        return scrollView
    }()

    // MARK: - Refreshable

    var refreshOperationQueue: OperationQueue = OperationQueue()

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

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

    func hideNoData() {
        // Does not conform to Stateful - probably no no data view
    }

    func noDataReload() {
        // Does not conform to Stateful - probably no no data view
    }

}

extension Stateful where Self: TBAViewController {

    func addNoDataView(_ noDataView: UIView) {
        DispatchQueue.main.async {
            self.view.insertSubview(noDataView, at: 0)
            self.view.autoPinEdgesToSuperviewEdges()
        }
    }

    func removeNoDataView(_ noDataView: UIView) {
        DispatchQueue.main.async {
            noDataView.removeFromSuperview()
        }
    }

}

extension Refreshable where Self: TBAViewController & Stateful {

    func hideNoData() {
        removeNoDataView()
    }

    func noDataReload() {
        if isDataSourceEmpty {
            showNoDataView()
        } else {
            removeNoDataView()
        }
    }

}
