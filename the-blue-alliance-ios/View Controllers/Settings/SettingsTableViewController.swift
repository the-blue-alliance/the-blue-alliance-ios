//
//  SettingsTableViewController.swift
//  The Blue Alliance
//
//  Created by Anas Merbouh on 18-05-20.
//  Copyright © 2018 The Blue Alliance. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BaseCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SwitchCell")
    }
    
    // MARK: - Interface Methods
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view configuration
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Account"
            
        case 1:
            return "Notifications"
            
        case 2:
            return "Info"
            
        case 3:
            return "Extra"
            
        default:
            fatalError("This section does not exist")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
            
        case 1:
            return 1
            
        case 2:
            return 4
            
        case 3:
            return 1
            
        default:
            fatalError("This section does not exist")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseCell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
            cell.populate(withTitle: "Enable myTBA")
            
            // Configure the cell's switch state depending on wether the user is connected or not
            if MyTBA.shared.authentication != nil {
                cell.switchToggle.isOn = true
            } else {
                cell.switchToggle.isOn = false
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
            cell.populate(withTitle: "Enable notifications")
            
            return cell

        case 2:
            let textLabels =  ["The Blue Alliance Website",  "The Blue Alliance for iOS is open source", "Contributors", "View changelog"]
            cell.textLabel?.text = textLabels [indexPath.row]
            
        case 3:
            cell.textLabel?.text = "Delete network cache"
            cell.textLabel?.textColor = .red
            cell.textLabel?.textAlignment = .center
            
        default:
            fatalError("This row does not exist")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // Handle authentification/unauthentification stuff
            break
            
        case 1:
            break
            
        case 2:
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
            
        case 3:
            let alertController = UIAlertController(title: "Delete network cache", message: "Are you sure you want to delete all the network cache data ? This action is irreversible.", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteAction) in
                // TODO: Handle network cache deletion
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (deleteAction) in
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        default:
            fatalError("This section does not exist")
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 || indexPath.section == 1 {
            return false
        }
        
        return true
    }
    
}
