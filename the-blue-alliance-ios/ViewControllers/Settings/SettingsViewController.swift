import FirebaseAnalytics
import FirebaseCrashlytics
import MyTBAKit
import TBAAPI
import UIKit
import TBAUtils

private enum SettingsSection: Int, CaseIterable {
    case info
    case networking
    case icons
    case privacy
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
/// A selectable app icon, backed by the `CFBundleIcons` entries the asset catalog
/// compiler generates from `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`.
private struct AppIconOption {
    /// The name passed to `setAlternateIconName`. `nil` represents the primary icon.
    let alternateName: String?
    let displayName: String
    let imageName: String
}

private enum PrivacyRow: Int, CaseIterable {
    case analytics
    case crashlytics
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dependencies.reporter.log("Settings")
    }

    // MARK: - Table View Data Source

    /// Sections in display order. The icon picker is dropped when the system can't switch
    /// icons, or when no alternates ship, so we never render a section that can't do anything.
    private lazy var visibleSections: [SettingsSection] = {
        let canSwitchIcons =
            UIApplication.shared.supportsAlternateIcons && !alternateAppIconNames.isEmpty
        return SettingsSection.allCases.filter { $0 != .icons || canSwitchIcons }
    }()

    private func section(at index: Int) -> SettingsSection? {
        guard visibleSections.indices.contains(index) else {
            return nil
        }
        return visibleSections[index]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = self.section(at: section) else {
            return 0
        }

        switch section {
        case .info:
            return InfoRow.allCases.count
        case .networking:
            return NetworkingRow.allCases.count
        case .icons:
            return appIconOptions.count
        case .privacy:
            return PrivacyRow.allCases.count
        case .debug:
            return DebugRow.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        guard let section = self.section(at: section) else {
            return nil
        }

        switch section {
        case .info:
            return "Info"
        case .networking:
            return "Networking"
        case .icons:
            return "App Icon"
        case .privacy:
            return "Privacy"
        case .debug:
            return "Debug"
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int)
        -> String?
    {
        switch self.section(at: section) {
        case .privacy:
            return
                "Analytics helps us understand how the app is used. Crash reports help us find and fix bugs. Both are sent to Firebase."
        case .debug:
            return "The Blue Alliance for iOS - \(Bundle.main.displayVersionString)"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard let section = self.section(at: indexPath.section) else {
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
                cell.detailTextLabel?.text =
                    dependencies.appSettings.cachePolicy.current.displayName
                cell.accessoryType = .disclosureIndicator
                return cell
            case .deleteNetworkCache:
                let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
                cell.textLabel?.text = "Delete network cache"
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        case .icons:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as IconTableViewCell
            let option = appIconOptions[indexPath.row]

            cell.viewModel = IconCellViewModel(
                name: option.displayName,
                imageName: option.imageName
            )
            cell.accessoryType = isCurrentAppIcon(option.alternateName) ? .checkmark : .none

            return cell
        case .privacy:
            let privacyRow = PrivacyRow.allCases[indexPath.row]
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            let toggle = UISwitch()
            switch privacyRow {
            case .analytics:
                cell.textLabel?.text = "Share Analytics"
                toggle.isOn = dependencies.appSettings.firebaseCollection.analyticsEnabled
                toggle.addAction(
                    UIAction { [weak self, unowned toggle] _ in self?.analyticsToggleChanged(toggle)
                    },
                    for: .valueChanged
                )
            case .crashlytics:
                cell.textLabel?.text = "Share Crash Reports"
                toggle.isOn = dependencies.appSettings.firebaseCollection.crashlyticsEnabled
                toggle.addAction(
                    UIAction { [weak self, unowned toggle] _ in
                        self?.crashlyticsToggleChanged(toggle)
                    },
                    for: .valueChanged
                )
            }
            cell.accessoryView = toggle
            cell.selectionStyle = .none
            return cell
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

        guard let section = self.section(at: indexPath.section) else {
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
        case .icons:
            setAppIcon(appIconOptions[indexPath.row].alternateName)
        case .privacy:
            break
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
            urlOpener.open(url)
        }
    }

    // MARK: - Icons Methods

    /// Check if the current app icon is the same as the passed app icon name.
    ///
    /// Used to show which app icon we currently have set.
    private func isCurrentAppIcon(_ icon: String?) -> Bool {
        return icon == UIApplication.shared.alternateIconName
    }

    private var primaryAppIconName: String? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any]
        else { return nil }
        return primaryIconsDictionary["CFBundleIconName"] as? String
    }

    /// The names of every alternate icon, as passed to `setAlternateIconName`.
    private lazy var alternateAppIconNames: [String] = {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let alternateIconsDictionary = iconsDictionary["CFBundleAlternateIcons"]
                as? [String: Any]
        else { return [] }
        return Array(alternateIconsDictionary.keys)
    }()

    /// The primary icon followed by every alternate icon, sorted for a stable order.
    private lazy var appIconOptions: [AppIconOption] = {
        let primary = AppIconOption(
            alternateName: nil,
            displayName: "The Blue Alliance",
            imageName: Self.previewImageName(for: primaryAppIconName ?? "AppIcon")
        )
        let alternates =
            alternateAppIconNames
            .map {
                AppIconOption(
                    alternateName: $0,
                    displayName: Self.displayName(for: $0),
                    imageName: Self.previewImageName(for: $0)
                )
            }
            .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
        return [primary] + alternates
    }()

    /// Icon Composer `.icon` files are compiled into a form that `UIImage(named:)` cannot load —
    /// asking for the icon's own name throws rather than returning `nil`. Each icon therefore
    /// ships a matching `<name>Preview` image set, rendered from the icon itself, for display here.
    private static func previewImageName(for iconName: String) -> String {
        return "\(iconName)Preview"
    }

    /// Turns an icon key like `ZachOrr` into a readable `Zach Orr`.
    private static func displayName(for iconName: String) -> String {
        return
            iconName
            .replacingOccurrences(
                of: "([a-z0-9])([A-Z])",
                with: "$1 $2",
                options: .regularExpression
            )
    }

    // `nil` is the primary icon. Reload after either outcome: a failed change leaves the
    // system's icon unchanged and the row has to show that.
    private func setAppIcon(_ alternateName: String?) {
        guard UIApplication.shared.supportsAlternateIcons,
            UIApplication.shared.alternateIconName != alternateName
        else {
            return
        }
        Task {
            do {
                try await UIApplication.shared.setAlternateIconName(alternateName)
            } catch {
                dependencies.reporter.record(error)
            }
            tableView.reloadData()
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
            let action = UIAlertAction(title: policy.displayName, style: .default) { _ in
                self.dependencies.appSettings.cachePolicy.current = policy
                Task { await self.api.setCachePolicy(policy) }
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
            if dependencies.appSettings.cachePolicy.current == policy {
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

        let deleteCacheAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task { await self.api.clearCache() }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteCacheAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Privacy Methods

    private func analyticsToggleChanged(_ sender: UISwitch) {
        dependencies.appSettings.firebaseCollection.analyticsEnabled = sender.isOn
        Analytics.setAnalyticsCollectionEnabled(sender.isOn)
    }

    private func crashlyticsToggleChanged(_ sender: UISwitch) {
        if sender.isOn {
            applyCrashlyticsEnabled(true)
            return
        }

        let alert = UIAlertController(
            title: "Turn off crash reports?",
            message:
                "If the app crashes, we won't receive a crash log to help us investigate and fix the issue.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in
                sender.setOn(true, animated: true)
                self.applyCrashlyticsEnabled(true)
            }
        )
        alert.addAction(
            UIAlertAction(title: "Turn Off", style: .destructive) { _ in
                self.applyCrashlyticsEnabled(false)
            }
        )
        present(alert, animated: true)
    }

    private func applyCrashlyticsEnabled(_ enabled: Bool) {
        dependencies.appSettings.firebaseCollection.crashlyticsEnabled = enabled
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(enabled)
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
