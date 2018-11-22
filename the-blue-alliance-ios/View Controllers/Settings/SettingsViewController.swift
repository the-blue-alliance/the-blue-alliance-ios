import CoreData
import Foundation
import UIKit

enum InfoURL: String {
    case website = "https://www.thebluealliance.com"
    case github = "https://github.com/the-blue-alliance/the-blue-alliance-ios"
}

private enum SettingsSection: Int {
    case info
    case debug
    case max
}

private enum InfoRow: Int {
    case website
    case repo
    // case changelog TODO: https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/193
    case max
}

private enum DebugRow: Int {
    case deleteNetworkCache
    case max
}

class SettingsViewController: UITableViewController, Persistable {

    private var urlOpener: URLOpener
    private var metadata: ReactNativeMetadata
    var persistentContainer: NSPersistentContainer
    var userDefaults: UserDefaults

    private let reactNativeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        return dateFormatter
    }()

    // MARK: - Init

    init(urlOpener: URLOpener, metadata: ReactNativeMetadata, persistentContainer: NSPersistentContainer, userDefaults: UserDefaults) {
        self.urlOpener = urlOpener
        self.metadata = metadata
        self.persistentContainer = persistentContainer
        self.userDefaults = userDefaults

        super.init(style: .grouped)

        title = "Settings"
        tabBarItem.image = UIImage(named: "ic_settings")

        metadata.metadataProvider.add(observer: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.max.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsSection.info.rawValue:
            return InfoRow.max.rawValue
        case SettingsSection.debug.rawValue:
            return DebugRow.max.rawValue
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SettingsSection.info.rawValue:
            return "Info"
        case SettingsSection.debug.rawValue:
            return "Debug"
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == SettingsSection.max.rawValue - 1 {
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

        var titleString: String

        switch indexPath.section {
        case SettingsSection.info.rawValue:
            switch indexPath.row {
            case InfoRow.website.rawValue:
                titleString = "The Blue Alliance Website"
            case InfoRow.repo.rawValue:
                titleString = "The Blue Alliance for iOS is open source"
            default:
                fatalError("This row does not exist")
            }
        case SettingsSection.debug.rawValue:
            switch indexPath.row {
            case DebugRow.deleteNetworkCache.rawValue:
                titleString = "Delete network cache"
            default:
                fatalError("This row does not exist")
            }
        default:
            fatalError("This section does not exist")
        }

        cell.textLabel?.text = titleString
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case SettingsSection.info.rawValue:
            switch indexPath.row {
            case InfoRow.website.rawValue:
                openTBAWebsite()
            case InfoRow.repo.rawValue:
                openGitHub()
            default:
                fatalError("This row does not exist")
            }
        case SettingsSection.debug.rawValue:
            switch indexPath.row {
            case DebugRow.deleteNetworkCache.rawValue:
                let alertController = UIAlertController(title: "Delete Network Cache", message: "Are you sure you want to delete all the network cache data?", preferredStyle: .alert)

                let deleteCacheAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (deleteAction) in
                    self.deleteNetworkCache()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                alertController.addAction(deleteCacheAction)
                alertController.addAction(cancelAction)

                self.present(alertController, animated: true, completion: nil)
            default:
                fatalError("This row does not exist")
            }

        default:
            fatalError("This section does not exist")
        }
    }

    // MARK: - Private Methods

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
        print(url)
        if urlOpener.canOpenURL(url) {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }

    internal func deleteNetworkCache() {
        userDefaults.clearSuccessfulRefreshes()
        TBAKit.clearLastModified()
    }

}

extension SettingsViewController: ReactNativeMetadataObservable {

    func metadataUpdated() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

}
