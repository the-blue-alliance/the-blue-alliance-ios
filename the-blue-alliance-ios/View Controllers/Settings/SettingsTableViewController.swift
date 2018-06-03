//
//  SettingsTableViewController.swift
//  The Blue Alliance
//
//  Created by Anas Merbouh on 18-05-20.
//  Copyright © 2018 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAKit

enum SettingsSection: Int {
    case info
    case extra
}

enum InfoRow: Int {
    case website
    case repo
    case contributors
    case changelog
}

enum ExtraRow: Int {
    case deleteNetworkCache
    case deleteAppData
}

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Table view configuration
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case SettingsSection.info.rawValue:
            var urlString: String?
            
            switch indexPath.row {
            case InfoRow.website.rawValue:
                urlString = "https://www.thebluealliance.com"
            case InfoRow.repo.rawValue:
                urlString = "https://github.com/the-blue-alliance/the-blue-alliance-ios"
            case InfoRow.contributors.rawValue:
                // TODO: Make a contributors list on Github
                break
            case InfoRow.changelog.rawValue:
                // TODO: Make a changelog
                break
            default:
                fatalError("This row does not exist")
            }
            
            if let urlString = urlString {
                let url = URL(string: urlString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        case SettingsSection.extra.rawValue:
            switch indexPath.row {
            case ExtraRow.deleteNetworkCache.rawValue:
                let alertController = UIAlertController(title: "Delete network cache", message: "Are you sure you want to delete all the network cache data ? This action is irreversible.", preferredStyle: .alert)
                
                let deleteCacheAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
                    TBAKit.clearLastModified()
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (deleteAction) in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                
                alertController.addAction(deleteCacheAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            case ExtraRow.deleteAppData.rawValue:
                let alertController = UIAlertController(title: "Delete app data", message: "Are you sure you want to delete the app data ? This action is irreversible.", preferredStyle: .alert)
                
                let deleteDataAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
                    // TODO: Handle app data deletion
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (deleteAction) in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                
                alertController.addAction(deleteDataAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            default:
                fatalError("This row does not exist")
            }
          
        default:
            fatalError("This section does not exist")
        }
    }
        
}
