import CoreData
import Foundation
import FirebaseMessaging
import UIKit

enum InfoURL: String {
    case website = "https://www.thebluealliance.com"
    case github = "https://github.com/the-blue-alliance/the-blue-alliance-ios"
}

private enum SettingsSection: Int, CaseIterable {
    case info
    case icons
    case debug
}

private enum InfoRow: Int, CaseIterable {
    case website
    case repo
    // case changelog TODO: https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/193
}

private enum DebugRow: Int, CaseIterable {
    case deleteNetworkCache
    case troubleshootNotifications
}

class SettingsViewController: TBATableViewController {

    private let messaging: Messaging
    private let metadata: ReactNativeMetadata
    private let myTBA: MyTBA
    private let pushService: PushService
    private let urlOpener: URLOpener

    private let reactNativeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        return dateFormatter
    }()

    // MARK: - Init

    init(messaging: Messaging, metadata: ReactNativeMetadata, myTBA: MyTBA, pushService: PushService, urlOpener: URLOpener, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.messaging = messaging
        self.metadata = metadata
        self.myTBA = myTBA
        self.pushService = pushService
        self.urlOpener = urlOpener

        super.init(style: .grouped, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        title = "Settings"
        tabBarItem.image = UIImage(named: "ic_settings")
        hidesBottomBarWhenPushed = false

        metadata.metadataProvider.add(observer: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(IconTableViewCell.self)
    }

    // MARK: - Private Methods

    private func normalizedSection(_ section: Int) -> SettingsSection? {
        var section = section
        if !UIApplication.shared.supportsAlternateIcons, section >= SettingsSection.icons.rawValue {
            section += 1
        }
        return SettingsSection(rawValue: section)!
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = SettingsSection.allCases.count
        // Remove our Icons section if they're not supported
        if !UIApplication.shared.supportsAlternateIcons {
            sections -= 1
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Remove our Icons section if they're not supported
        guard let section = normalizedSection(section) else {
            return 0
        }

        switch section {
        case .info:
            return InfoRow.allCases.count
        case .icons:
            return alternateAppIcons.count + 1 // +1 for default icon
        case .debug:
            return 1 // For now, don't show troubleshoot notifications
            // return DebugRow.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = normalizedSection(section) else {
            return nil
        }

        switch section {
        case .info:
            return "Info"
        case .icons:
            return "App Icon"
        case .debug:
            return "Debug"
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let section = normalizedSection(section) else {
            return nil
        }
        if section == .debug {
            let reactNativeVersion: String = {
                if let bundleCreated = metadata.bundleCreated {
                    return "\(reactNativeDateFormatter.string(from: bundleCreated)) (\(metadata.bundleGeneration))"
                } else {
                    return "Local Version"
                }
            }()
            return [
                "The Blue Alliance for iOS - \(Bundle.main.displayVersionString)",
                "TBA RN - \(reactNativeVersion)"
            ].joined(separator: "\n")
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = normalizedSection(indexPath.section) else {
            fatalError("This section does not exist")
        }

        switch section {
        case .info:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

            guard let row = InfoRow(rawValue: indexPath.row) else {
                fatalError("This row does not exist")
            }
            let titleString: String = {
                switch row {
                case .website:
                    return "The Blue Alliance Website"
                case .repo:
                    return "The Blue Alliance for iOS is open source"
                }
            }()

            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = titleString

            return cell
        case .icons:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as IconTableViewCell

            let viewModel: IconCellViewModel = {
                if indexPath.row == 0 {
                    return IconCellViewModel(name: "The Blue Alliance", imageName: primaryAppIconName ?? "AppIcon")
                } else {
                    let alternateName = Array(alternateAppIcons.keys)[indexPath.row - 1]
                    guard let alternateIconName = alternateAppIcons[alternateName] else {
                        fatalError("Unable to find alternate icon for \(alternateName)")
                    }
                    return IconCellViewModel(name: alternateName, imageName: alternateIconName)
                }
            }()

            cell.viewModel = viewModel

            // Show currently-selected app icon
            if isCurrentAppIcon(viewModel.name) || (isCurrentAppIcon(nil) && indexPath.row == 0) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell
        case .debug:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

            guard let row = DebugRow(rawValue: indexPath.row) else {
                fatalError("This row does not exist")
            }

            let titleString: String = {
                switch row {
                case .deleteNetworkCache:
                    return "Delete network cache"
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

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Override so we don't get colored headers
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = normalizedSection(indexPath.section) else {
            fatalError("This section does not exist")
        }

        switch section {
        case .info:
            guard let row = InfoRow(rawValue: indexPath.row) else {
                fatalError("This row does not exist")
            }
            switch row {
            case .website:
                openTBAWebsite()
            case .repo:
                openGitHub()
            }
        case .icons:
            if indexPath.row == 0 {
                setDefaultAppIcon()
            } else {
                let alternateName = Array(alternateAppIcons.keys)[indexPath.row - 1]
                setAlternateAppIcon(alternateName)
            }
        case .debug:
            guard let row = DebugRow(rawValue: indexPath.row) else {
                fatalError("This row does not exist")
            }
            switch row {
            case .deleteNetworkCache:
                showDeleteNetworkCache()
            case .troubleshootNotifications:
                pushTroubleshootNotifications()
            }
        }
    }

    // MARK: - Private Methods

    // MARK: - Info Methods

    internal func openTBAWebsite() {
        if let url = URL(string: InfoURL.website.rawValue) {
            openURL(url: url)
        }
    }

    internal func openGitHub() {
        if let url = URL(string: InfoURL.github.rawValue) {
            openURL(url: url)
        }
    }

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
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last else { return nil }
        return lastIcon
    }

    /*
     Key is the name, value is the image name.
    */
    private lazy var alternateAppIcons: [String: String] = {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
            let alternateIconsDictionary = iconsDictionary["CFBundleAlternateIcons"] as? [String:Any] else { return [:] }

        var alternateAppIcons: [String: String] = [:]
        alternateIconsDictionary.forEach({ (key, value) in
            guard let iconDictionary = value as? [String:Any],
                let iconFiles = iconDictionary["CFBundleIconFiles"] as? [String],
                let lastIcon = iconFiles.last else { return }
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

        UIApplication.shared.setAlternateIconName(nil, completionHandler: { _ in
            self.reloadIconsSection()
        })
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

        UIApplication.shared.setAlternateIconName(alternateName, completionHandler: { _ in
            self.reloadIconsSection()
        })
    }

    private func reloadIconsSection() {
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: SettingsSection.icons.rawValue), with: .automatic)
        }
    }

    // MARK: - Debug Methods

    private func showDeleteNetworkCache() {
        let alertController = UIAlertController(title: "Delete Network Cache", message: "Are you sure you want to delete all the network cache data?", preferredStyle: .alert)

        let deleteCacheAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (deleteAction) in
            self.deleteNetworkCache()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteCacheAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    internal func deleteNetworkCache() {
        userDefaults.clearSuccessfulRefreshes()
        tbaKit.clearLastModified()
    }

    private func pushTroubleshootNotifications() {
        let notificationsViewController = NotificationsViewController(messaging: messaging, myTBA: myTBA, pushService: pushService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        let nav = UINavigationController(rootViewController: notificationsViewController)
        navigationController?.showDetailViewController(nav, sender: nil)
    }

}

extension SettingsViewController: ReactNativeMetadataObservable {

    func metadataUpdated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
