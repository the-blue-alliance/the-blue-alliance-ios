import MyTBAKit
import TBAAPI
import UIKit

private enum SettingsSection: Int, CaseIterable {
    case info
    case networking
    case debug
}

private enum InfoRow: String, CaseIterable {
    case website = "https://www.thebluealliance.com"
    case github = "https://github.com/the-blue-alliance/the-blue-alliance-ios"
    case testFlight = "https://testflight.apple.com/join/gz7RmdS7"
}

private enum NetworkingRow: Int, CaseIterable {
    case cachePolicy
    case deleteNetworkCache
}

private enum DebugRow: Int, CaseIterable {
    case troubleshootNotifications
}

private extension TBAAPI.CachePolicy {
    var displayName: String {
        switch self {
        case .default: return "Default"
        case .bypass: return "Bypass Cache"
        }
    }
}

class SettingsViewController: TBATableViewController {

    private let fcmTokenProvider: any FCMTokenProvider
    private let pushService: any PushServiceProtocol

    // MARK: - Init

    init(
        fcmTokenProvider: any FCMTokenProvider,
        pushService: any PushServiceProtocol,
        dependencies: Dependencies
    ) {
        self.fcmTokenProvider = fcmTokenProvider
        self.pushService = pushService

        super.init(style: .grouped, dependencies: dependencies)

        title = RootType.settings.title
        tabBarItem.image = RootType.settings.icon

        hidesBottomBarWhenPushed = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(IconTableViewCell.self)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else {
            return 0
        }

        switch section {
        case .info:
            return InfoRow.allCases.count
        case .networking:
            return NetworkingRow.allCases.count
        case .debug:
            return DebugRow.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        guard let section = SettingsSection(rawValue: section) else {
            return nil
        }

        switch section {
        case .info:
            return "Info"
        case .networking:
            return "Networking"
        case .debug:
            return "Debug"
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int)
        -> String?
    {
        guard SettingsSection(rawValue: section) == .debug else {
            return nil
        }
        return "The Blue Alliance for iOS - \(Bundle.main.displayVersionString)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard let section = SettingsSection(rawValue: indexPath.section) else {
            fatalError("This section does not exist")
        }

        switch section {
        case .info:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

            let infoRow = InfoRow.allCases[indexPath.row]
            let titleString: String = {
                switch infoRow {
                case .website:
                    return "The Blue Alliance website"
                case .github:
                    return "The Blue Alliance for iOS is open source"
                case .testFlight:
                    return "Join The Blue Alliance TestFlight"
                }
            }()

            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = titleString

            return cell
        case .networking:
            let networkingRow = NetworkingRow.allCases[indexPath.row]
            switch networkingRow {
            case .cachePolicy:
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Cache Policy"
                cell.detailTextLabel?.text = api.cachePolicy.displayName
                cell.accessoryType = .disclosureIndicator
                return cell
            case .deleteNetworkCache:
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Delete network cache"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        case .debug:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

            let debugRow = DebugRow.allCases[indexPath.row]
            let titleString: String = {
                switch debugRow {
                case .troubleshootNotifications:
                    return "Troubleshoot notifications"
                }
            }()

            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = titleString
            return cell
        }
    }

    // MARK: - Table View Delegate

    override func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        // Override so we don't get colored headers
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = SettingsSection(rawValue: indexPath.section) else {
            fatalError("This section does not exist")
        }

        switch section {
        case .info:
            let infoRow = InfoRow.allCases[indexPath.row]
            if let url = URL(string: infoRow.rawValue) {
                openURL(url: url)
            }
        case .networking:
            let networkingRow = NetworkingRow.allCases[indexPath.row]
            switch networkingRow {
            case .cachePolicy:
                showCachePolicyPicker(from: indexPath)
            case .deleteNetworkCache:
                showDeleteNetworkCache()
            }
        case .debug:
            let debugRow = DebugRow.allCases[indexPath.row]
            switch debugRow {
            case .troubleshootNotifications:
                pushTroubleshootNotifications()
            }
        }
    }

    // MARK: - Private Methods

    // MARK: - Info Methods

    private func openURL(url: URL) {
        if urlOpener.canOpenURL(url) {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: - Icons Methods

    /**
     Check if the current app icon is the same as the passed app icon name.
    
     Used to show which app icon we currently have set.
    */
    private func isCurrentAppIcon(_ icon: String?) -> Bool {
        return icon == UIApplication.shared.alternateIconName
    }

    private var primaryAppIconName: String? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last
        else { return nil }
        return lastIcon
    }

    /*
     Key is the name, value is the image name.
    */
    private lazy var alternateAppIcons: [String: String] = {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let alternateIconsDictionary = iconsDictionary["CFBundleAlternateIcons"]
                as? [String: Any]
        else { return [:] }

        var alternateAppIcons: [String: String] = [:]
        alternateIconsDictionary.forEach({ (key, value) in
            guard let iconDictionary = value as? [String: Any],
                let iconFiles = iconDictionary["CFBundleIconFiles"] as? [String],
                let lastIcon = iconFiles.last
            else { return }
            alternateAppIcons[key] = lastIcon
        })
        return alternateAppIcons
    }()

    private func setDefaultAppIcon() {
        // Only change icons if it's supported by the OS
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }

        // Only set the default app icon if we have an alternate icon set
        guard UIApplication.shared.alternateIconName != nil else {
            return
        }

        UIApplication.shared.setAlternateIconName(
            nil,
            completionHandler: { _ in
                self.reloadIconsSection()
            }
        )
    }

    private func setAlternateAppIcon(_ alternateName: String) {
        // Only change icons if it's supported by the OS
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }

        // Only set the the alternate icon if it's different from the icon we have currently set
        guard UIApplication.shared.alternateIconName != alternateName else {
            return
        }

        UIApplication.shared.setAlternateIconName(
            alternateName,
            completionHandler: { _ in
                self.reloadIconsSection()
            }
        )
    }

    private func reloadIconsSection() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Networking Methods

    private func showCachePolicyPicker(from indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: "Cache Policy",
            message: nil,
            preferredStyle: .actionSheet
        )

        for policy in TBAAPI.CachePolicy.allCases {
            let action = UIAlertAction(title: policy.displayName, style: .default) {
                [weak self] _ in
                guard let self else { return }
                self.dependencies.appSettings.cachePolicy.current = policy
                self.api.setCachePolicy(policy)
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            if api.cachePolicy == policy {
                action.setValue(true, forKey: "checked")
            }
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let popover = alertController.popoverPresentationController,
            let cell = tableView.cellForRow(at: indexPath)
        {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }

        present(alertController, animated: true)
    }

    private func showDeleteNetworkCache() {
        let alertController = UIAlertController(
            title: "Delete Network Cache",
            message: "Are you sure you want to delete all the network cache data?",
            preferredStyle: .alert
        )

        let deleteCacheAction = UIAlertAction(title: "Delete", style: .destructive) {
            [weak self] _ in
            self?.api.clearCache()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteCacheAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Debug Methods

    private func pushTroubleshootNotifications() {
        let notificationsViewController = NotificationsViewController(
            fcmTokenProvider: fcmTokenProvider,
            pushService: pushService,
            dependencies: dependencies
        )
        navigationController?.pushViewController(notificationsViewController, animated: true)
    }

}
