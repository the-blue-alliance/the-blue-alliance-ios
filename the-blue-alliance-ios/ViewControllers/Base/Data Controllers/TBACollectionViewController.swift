import Foundation
import MyTBAKit
import TBAAPI
import UIKit

class TBACollectionViewController: UICollectionViewController, Alertable, DependenciesProviding,
    Navigatable
{

    let dependencies: Dependencies

    // MARK: - Refreshable

    var currentRefreshTask: Task<Void, Never>?

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return []
    }

    // MARK: - Init

    init(
        collectionViewLayout: UICollectionViewLayout = UICollectionViewFlowLayout(),
        dependencies: Dependencies
    ) {
        self.dependencies = dependencies

        super.init(collectionViewLayout: collectionViewLayout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.systemGroupedBackground
        collectionView.delegate = self
        collectionView.registerReusableCell(BasicCollectionViewCell.self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        (self as? any Refreshable)?.updateRefreshOnAppear()
    }

}

extension Refreshable where Self: TBACollectionViewController {

    var refreshControl: UIRefreshControl? {
        get {
            return collectionView.refreshControl
        }
        set {
            collectionView.refreshControl = newValue
        }
    }

    var refreshView: UIScrollView {
        return collectionView
    }

}
