import CoreData
import Foundation
import MyTBAKit
import TBAKit
import UIKit

protocol MatchQueryOptionsDelegate: AnyObject {
    func updateQuery(query: MatchQueryOptions)
}

// Backing enums to setup our table view data source
private enum QuerySections: String, CaseIterable {
    case sort = "Sort"
    case filter = "Filter"
}

private enum SortRows: CaseIterable {
    case reverse
}

private enum FilterRows: CaseIterable {
    case favorites
}

private protocol QueryableOptions {
    static func defaultQuery() -> Self

    var isDefault: Bool { get }
}

// Backing structs to power our data
struct MatchQueryOptions: QueryableOptions {

    var sort: MatchSortOptions
    var filter: MatchFilterOptions

    static func defaultQuery() -> MatchQueryOptions {
        return MatchQueryOptions(sort: MatchQueryOptions.MatchSortOptions.defaultQuery(), filter: MatchQueryOptions.MatchFilterOptions.defaultQuery())
    }

    struct MatchSortOptions: QueryableOptions {
        var reverse: Bool

        static func defaultQuery() -> MatchSortOptions {
            return MatchSortOptions(reverse: false)
        }

        var isDefault: Bool {
            return reverse == false
        }
    }

    struct MatchFilterOptions: QueryableOptions {
        var favorites: Bool

        static func defaultQuery() -> MatchFilterOptions {
            return MatchFilterOptions(favorites: false)
        }

        var isDefault: Bool {
            return favorites == false
        }
    }

    var isDefault: Bool {
        return sort.isDefault && filter.isDefault
    }
}

class MatchQueryOptionsViewController: TBATableViewController {

    private var myTBA: MyTBA
    private var query: MatchQueryOptions

    weak var delegate: MatchQueryOptionsDelegate?

    init(query: MatchQueryOptions, myTBA: MyTBA, dependencies: Dependencies) {
        self.query = query
        self.myTBA = myTBA

        super.init(style: .plain, dependencies: dependencies)

        title = "Match Sort/Filter"

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissMatchQuery))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // If myTBA isn't enabled, disable filtering for myTBA Favorites
        var sections = QuerySections.allCases.count
        if !myTBA.isAuthenticated {
            sections = sections - 1
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let querySection = querySection(index: section) else {
            fatalError("Unsupported query section")
        }
        switch querySection {
        case .sort:
            return SortRows.allCases.count
        case .filter:
            return FilterRows.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let querySection = querySection(index: indexPath.section) else {
            fatalError("Unsupported query section")
        }
        let cell: SwitchTableViewCell = {
            switch querySection {
            case .sort:
                let switchCell = SwitchTableViewCell(switchToggled: { [weak self] (_ sender: UISwitch) in
                    guard let self = self else { return }
                    self.query.sort.reverse = sender.isOn
                    self.delegate?.updateQuery(query: self.query)
                })
                switchCell.textLabel?.text = "Reverse"
                switchCell.detailTextLabel?.text = "Show matches in ascending order"
                switchCell.switchView.isOn = self.query.sort.reverse
                return switchCell
            case .filter:
                let switchCell = SwitchTableViewCell(switchToggled: { [weak self] (_ sender: UISwitch) in
                    guard let self = self else { return }
                    self.query.filter.favorites = sender.isOn
                    self.delegate?.updateQuery(query: self.query)
                })
                switchCell.textLabel?.text = "Favorites"
                switchCell.detailTextLabel?.text = "Show only matches with myTBA favorite teams playing"
                switchCell.detailTextLabel?.numberOfLines = 0
                switchCell.switchView.isOn = self.query.filter.favorites
                return switchCell
            }
        }()
        cell.detailTextLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let querySection = querySection(index: section) else {
            fatalError("Unsupported query section")
        }
        return querySection.rawValue
    }

    // MAKR: - Private Functions

    private func querySection(index: Int) -> QuerySections? {
        let sections = QuerySections.allCases
        return index < sections.count ? sections[index] : nil
    }

    @objc private func dismissMatchQuery() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}
