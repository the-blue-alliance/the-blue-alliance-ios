import UIKit

class SelectViewController<T: SelectTableViewControllerDelegate>: UINavigationController {

    private let selectTableViewController: SelectTableViewController<T>
    weak var selectTableViewControllerDelegate: T? {
        didSet {
            selectTableViewController.delegate = selectTableViewControllerDelegate
        }
    }

    init(current: T.OptionType?, options: [T.OptionType]) {
        selectTableViewController = SelectTableViewController<T>(current: current, options: options)
        super.init(rootViewController: selectTableViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

protocol SelectTableViewControllerDelegate: AnyObject {

    associatedtype OptionType: Comparable

    func optionSelected(_ option: OptionType)
    func titleForOption(_ option: OptionType) -> String

}

private class SelectTableViewController<T: SelectTableViewControllerDelegate>: UITableViewController {

    private let current: T.OptionType?
    private let options: [T.OptionType]
    weak var delegate: T?

    init(current: T.OptionType?, options: [T.OptionType]) {
        self.current = current
        self.options = options

        super.init(style: .plain)
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
        if current == option {
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

        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private Methods

    @objc private func dismissModal(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
    }

}
