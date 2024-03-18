import CoreData
import Foundation
import TBAData
import TBAKit
import UIKit

struct BreakdownRow: Hashable {

    enum BreakdownRowType {
        case normal
        case subtotal
        case total
    }

    var title: String
    var red: [AnyHashable?] = []
    var blue: [AnyHashable?] = []
    var type: BreakdownRowType = .normal
    var offset: Int = 0 // Used so we can have rows with duplicate titles

    var redElements: [BreakdownElement] {
        return red.compactMap({ $0 as? BreakdownElement })
    }
    var blueElements: [BreakdownElement] {
        return blue.compactMap({ $0 as? BreakdownElement })
    }

}

class MatchBreakdownViewController: TBATableViewController, Refreshable, Observable {

    let match: Match
    let breakdownConfigurator: MatchBreakdownConfigurator.Type?

    var dataSource: TableViewDataSource<String?, BreakdownRow>!

    // MARK: - Observable

    typealias ManagedType = Match
    lazy var contextObserver: CoreDataContextObserver<Match> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: - Init

    init(match: Match, dependencies: Dependencies) {
        self.match = match

        if match.event.year == 2015 {
            breakdownConfigurator = MatchBreakdownConfigurator2015.self
        } else if match.event.year == 2016 {
            breakdownConfigurator = MatchBreakdownConfigurator2016.self
        } else if match.event.year == 2017 {
            breakdownConfigurator = MatchBreakdownConfigurator2017.self
        } else if match.event.year == 2018 {
            breakdownConfigurator = MatchBreakdownConfigurator2018.self
        } else if match.event.year == 2019 {
            breakdownConfigurator = MatchBreakdownConfigurator2019.self
        } else if match.event.year == 2020 {
            breakdownConfigurator = MatchBreakdownConfigurator2020.self
        } else if match.event.year == 2021 {
            breakdownConfigurator = MatchBreakdownConfigurator2020.self
        } else if match.event.year == 2022 {
            breakdownConfigurator = MatchBreakdownConfigurator2022.self
        } else if match.event.year == 2024 {
            breakdownConfigurator = MatchBreakdownConfigurator2024.self
        }else {
            breakdownConfigurator = nil
        }

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(MatchBreakdownTableViewCell.self)
        tableView.insetsContentViewsToSafeArea = false

        tableView.dataSource = dataSource
        setupDataSource()

        let breakdownSupported = (breakdownConfigurator != nil)
        if breakdownSupported {
            configureDataSource(match.breakdown)

            contextObserver.observeObject(object: match, state: .updated) { (match, _) in
                DispatchQueue.main.async {
                    self.configureDataSource(match.breakdown)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.disableRefreshing()
            }
        }
    }

    // MARK: - Methods

    func setupDataSource() {
        dataSource = TableViewDataSource<String?, BreakdownRow>(tableView: tableView) { (tableView, indexPath, row) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MatchBreakdownTableViewCell
            cell.titleText = row.title
            cell.redElements = row.redElements
            cell.blueElements = row.blueElements
            cell.type = row.type
            return cell
        }
        dataSource.delegate = self
        dataSource.statefulDelegate = self
    }

    func configureDataSource(_ breakdown: [String: Any]?) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()

        let red = breakdown?["red"] as? [String: Any]
        let blue = breakdown?["blue"] as? [String: Any]

        if let breakdownConfigurator = breakdownConfigurator {
            breakdownConfigurator.configureDataSource(&snapshot, breakdown, red, blue)
        }

        dataSource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        if breakdownConfigurator == nil {
            return nil
        }
        return match.key
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return dataSource.isDataSourceEmpty
    }

    @objc func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchMatch(key: match.key, { [self] (result, notModified) in
            guard case .success(let object) = result, let match = object, !notModified else {
                return
            }

            let context = persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                Match.insert(match, in: context)
            }, saved: { [unowned self] in
                markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: errorRecorder)
        })
        addRefreshOperations([operation])
    }

}

extension MatchBreakdownViewController: Stateful {

    var noDataText: String? {
        guard breakdownConfigurator == nil else {
            return "No breakdown for match"
        }
        return "\(match.event.year) Match Breakdowns are not supported - try updating your app via the App Store."
    }

}
