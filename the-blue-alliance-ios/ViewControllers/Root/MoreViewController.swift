import Foundation
import PureLayout
import UIKit

/// The sections that don't fit in the tab bar beside the search pill.
class MoreViewController: UIViewController {

    private let items: [RootType]
    private let makeViewController: (RootType) -> UIViewController

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    init(items: [RootType], makeViewController: @escaping (RootType) -> UIViewController) {
        self.items = items
        self.makeViewController = makeViewController

        super.init(nibName: nil, bundle: nil)

        title = RootType.more.title
        tabBarItem.image = RootType.more.icon
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // The navigation bar is transparent; the blue behind it is this view showing through.
        view.backgroundColor = UIColor.navigationBarTintColor

        view.addSubview(tableView)
        tableView.autoPinEdge(toSuperviewSafeArea: .top)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }

}

extension MoreViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.image = item.icon
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

}

extension MoreViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = makeViewController(items[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }

}
