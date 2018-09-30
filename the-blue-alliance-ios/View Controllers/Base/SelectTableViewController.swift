import CoreData
import UIKit

protocol SelectTableViewControllerDelegate: AnyObject {

    associatedtype OptionType: Comparable

    func optionSelected(_ option: OptionType)
    func titleForOption(_ option: OptionType) -> String

    func refresh()
    func shouldNoDataRefresh() -> Bool
}

extension SelectTableViewControllerDelegate {

    func refresh() {
        // NOP
    }

    func shouldNoDataRefresh() -> Bool {
        return false
    }
}

class SelectTableViewController<Delegate: SelectTableViewControllerDelegate>: TBATableViewController {

    private let current: Delegate.OptionType?
    var options: [Delegate.OptionType]
    private let willPush: Bool
    weak var delegate: Delegate?

    init(current: Delegate.OptionType?, options: [Delegate.OptionType], willPush: Bool = false, persistentContainer: NSPersistentContainer) {
        self.current = current
        self.options = options
        self.willPush = willPush

        super.init(persistentContainer: persistentContainer)

        disableRefreshing()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissModal(_:)))
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

    @objc override func refresh() {
        delegate?.refresh()
    }

    override func shouldNoDataRefresh() -> Bool {
        return delegate?.shouldNoDataRefresh() ?? false
    }

    // MARK: - Private Methods

    @objc private func dismissModal(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
    }

}
