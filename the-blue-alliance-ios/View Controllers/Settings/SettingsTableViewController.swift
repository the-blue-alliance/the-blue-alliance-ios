//
//  SettingsTableViewController.swift
//  The Blue Alliance
//
//  Created by Anas Merbouh on 18-05-20.
//  Copyright © 2018 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - View's lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view configuration
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            var urlString: String?
            
            switch indexPath.row {
            case 0:
                urlString = "https://www.thebluealliance.com"
                self.tableView.deselectRow(at: indexPath, animated: true)
            case 1:
                urlString = "https://github.com/the-blue-alliance/the-blue-alliance-ios"
                self.tableView.deselectRow(at: indexPath, animated: true)
            case 2:
                // TODO: Make a contributors list on Github
                self.tableView.deselectRow(at: indexPath, animated: true)
            case 3:
                // TODO: Make a changelog
                self.tableView.deselectRow(at: indexPath, animated: true)
            default:
                fatalError("This row does not exist")
            }
            
            if let urlString = urlString {
                let url = URL(string: urlString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        case 1:
            if indexPath.row == 0 {
                let alertController = UIAlertController(title: "Delete network cache", message: "Are you sure you want to delete all the network cache data ? This action is irreversible.", preferredStyle: .alert)
                
                let deleteCacheAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
                    // TODO: Handle network cache deletion
                    
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (deleteAction) in
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                
                alertController.addAction(deleteCacheAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
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
            }
            
            
        default:
            fatalError("This section does not exist")
        }
    }
        
}
