import TBAAPI
import CoreData
import Foundation
import TBAKit
import TBAUtils
import UIKit

class TBACollectionViewController: UICollectionViewController, DataController, Navigatable, SimpleRefreshable {

    let dependencies: Dependencies

    var api: TBAAPI {
        return dependencies.api
    }
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

    // MARK: - Refreshable

    var refreshOperationQueue: OperationQueue = OperationQueue()

    // MARK: - SimpleRefreshable

    var refreshTask: Task<Void, any Error>?
    weak var refreshDelegate: (any RefreshDelegate)?

    // MARK: - Stateful

    var noDataViewController: NoDataViewController = NoDataViewController()

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return []
    }

    // MARK: - Init

    init(collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout(), dependencies: Dependencies) {
        self.dependencies = dependencies

        super.init(collectionViewLayout: collectionViewLayout)

        refreshDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.systemGroupedBackground
        collectionView.delegate = self

        collectionView.registerReusableSupplementaryView(elementKind: UICollectionView.elementKindSectionHeader, TitleCollectionHeaderView.self)

        collectionView.registerReusableCell(BasicCollectionViewCell.self)
        collectionView.registerReusableCell(ListCollectionViewCell.self)

        enableRefreshing()
    }

    // MARK: - SimpleRefreshable

    @objc func handleRefreshControlTrigger() {
        Task {
            refresh()
        }
    }

    func performRefresh() async throws {
        fatalError("Should implement performRefresh in sublcass")
    }
}

extension TBACollectionViewController: RefreshDelegate {}

// TODO: Move this out
class TitleCollectionHeaderView: UICollectionReusableView, Reusable {
    let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    @MainActor
    private func setupViews() {
        backgroundColor = UIColor.tableViewHeaderColor

        addSubview(headerTitleLabel)
        NSLayoutConstraint.activate([
            headerTitleLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            // TODO: I think to get this to match table view, we make this a >= constraint
            // The content should collapse in itself
            headerTitleLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: -8),
            headerTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            headerTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
        // headerTitleLabel.autoPinEdgesToSuperviewEdges(with: .init(top: 8, left: 8, bottom: 8, right: 8))
    }

    // MARK: - Reuse

    @MainActor
    override func prepareForReuse() {
        super.prepareForReuse()

        headerTitleLabel.text = nil
    }

    // MARK: - Configuration

    // Method to set the data for the header
    @MainActor
    func configure(with title: String?) {
        headerTitleLabel.text = title
    }
}

extension RefreshDelegate where Self: TBACollectionViewController & SimpleRefreshable {
    @MainActor func refreshDidStart() {
        // TODO: Add this back in
        // hideNoData()

        // TODO: We should really debounce this animation so it only occurs if we're refreshing after
        // maybe let's say like... half a second? Otherwise we get a flash when showing the view.
        let refreshControlHeight = refreshView.refreshControl?.frame.size.height ?? 0
        refreshView.setContentOffset(CGPoint(x: 0, y: -refreshControlHeight), animated: true)
        refreshView.refreshControl?.beginRefreshing()
    }

    @MainActor func refreshDidEnd(error: (any Error)?) {
        refreshView.refreshControl?.endRefreshing()

        // TODO: Remove this
        // noDataReload(error: error)
    }
}

extension RefreshDelegate where Self: TBACollectionViewController & SimpleRefreshable & Stateful {
}

extension Refreshable where Self: TBACollectionViewController {

    var refreshView: UIScrollView {
        return collectionView
    }

    func hideNoData() {
        // Does not conform to Stateful - probably no no data view
    }

    func noDataReload() {
        // Does not conform to Stateful - probably no no data view
    }
}

extension SimpleRefreshable where Self: TBACollectionViewController {
    var refreshView: UIScrollView {
        return collectionView
    }
}

extension Stateful where Self: TBACollectionViewController {

    @MainActor func addNoDataView(_ noDataView: UIView) {
        self.collectionView.backgroundView = noDataView
    }

    @MainActor func removeNoDataView(_ view: UIView) {
        self.collectionView.backgroundView = nil
    }
}
