import CoreData
import TBAKit
import UIKit

protocol SelectTableViewControllerDelegate: AnyObject {

    associatedtype OptionType: Comparable

    func optionSelected(_ option: OptionType)
    func titleForOption(_ option: OptionType) -> String
}

class SelectTableViewController<Delegate: SelectTableViewControllerDelegate>: TBATableViewController, Refreshable {

    private(set) var current: Delegate.OptionType?
    var options: [Delegate.OptionType] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private let willPush: Bool
    weak var delegate: Delegate?

    init(current: Delegate.OptionType?, options: [Delegate.OptionType], willPush: Bool = false, dependencies: Dependencies) {
        self.current = current
        self.options = options
        self.willPush = willPush

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        disableRefreshing()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let option = options[indexPath.row]
        if willPush {
            cell.accessoryType = .disclosureIndicator
        } else if current == option {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.textLabel?.text = delegate?.titleForOption(option)
        cell.tintColor = UIColor.tabBarTintColor

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)

        let option = options[indexPath.row]
        delegate?.optionSelected(option)

        if !willPush {
            dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        return nil
    }

    var automaticRefreshInterval: DateComponents? {
        return nil
    }

    var automaticRefreshEndDate: Date? {
        return nil
    }

    var isDataSourceEmpty: Bool {
        return false
    }

    @objc func refresh() {
        // NOP
    }

    // MARK: - Private Methods

    @objc private func dismissModal(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
    }

}
