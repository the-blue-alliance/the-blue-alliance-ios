import Foundation
import MyTBAKit
import TBAAPI
import UIKit

class TBATableViewController: UITableViewController, Alertable, DependenciesProviding, Navigatable {

    let dependencies: Dependencies

    // MARK: - Refreshable

    var currentRefreshTask: Task<Void, Never>?

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return []
    }

    var containerAccessoryView: UIView? {
        return nil
    }

    // MARK: - Init

    init(style: UITableView.Style = .plain, dependencies: Dependencies) {
        self.dependencies = dependencies

        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.tableFooterView = UIView.init(frame: .zero)
        tableView.delegate = self
        tableView.registerReusableCell(BasicTableViewCell.self)

        tableView.sectionHeaderTopPadding = 0
        tableView.contentInsetAdjustmentBehavior = .automatic

        // The navigation bar is transparent. A screen pushed directly under it paints the blue
        // behind it here; inside a container the safe area top is zero and this has no height.
        // Pinned to the frame guide so it doesn't scroll with the content.
        let barBackdrop = UIView()
        barBackdrop.backgroundColor = UIColor.navigationBarTintColor
        barBackdrop.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(barBackdrop)
        NSLayoutConstraint.activate([
            barBackdrop.topAnchor.constraint(equalTo: tableView.frameLayoutGuide.topAnchor),
            barBackdrop.leadingAnchor.constraint(equalTo: tableView.frameLayoutGuide.leadingAnchor),
            barBackdrop.trailingAnchor.constraint(
                equalTo: tableView.frameLayoutGuide.trailingAnchor
            ),
            barBackdrop.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.topAnchor),
        ])

        if !isInContainer {
            (self as? any Refreshable)?.enableRefreshing()
        }
    }

    // A container refreshes its selected tab and cancels its tabs' refreshes when popped.
    // A screen pushed on its own does both itself.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !isInContainer {
            (self as? any Refreshable)?.refresh()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        (self as? any Refreshable)?.updateRefreshOnAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent, !isInContainer {
            (self as? any Refreshable)?.cancelRefresh()
        }
    }

    private var isInContainer: Bool {
        parent is ContainerViewController
    }

    // MARK: - UITableViewDelegate

    override func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        if type(of: view) == UITableViewHeaderFooterView.self,
            let view = view as? UITableViewHeaderFooterView
        {
            // Setup text
            view.textLabel?.textColor = UIColor.white
            view.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)

            // Set custom background color
            let headerView = UIView()
            headerView.backgroundColor = UIColor.tableViewHeaderColor
            view.backgroundView = headerView
        }
    }

}

extension Refreshable where Self: TBATableViewController {

    var refreshControl: UIRefreshControl? {
        get {
            return tableView.refreshControl
        }
        set {
            tableView.refreshControl = newValue
        }
    }

    var refreshView: UIScrollView {
        return tableView
    }

}
