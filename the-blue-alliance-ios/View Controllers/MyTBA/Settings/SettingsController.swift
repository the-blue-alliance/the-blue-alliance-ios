//
//  SettingsController.swift
//  the-blue-alliance-ios
//
//  Created by Anas Merbouh on 18-05-06.
//  Copyright © 2018 The Blue Alliance. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {
    
    @IBOutlet weak var myTBASwitch: UISwitch!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    // MARK: - View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersionLabel.text = "App version: \(version)"
        } else {
            let indexPath = IndexPath(row: 4, section: 2)
            let appVersionCell = tableView.cellForRow(at: indexPath)
            
            appVersionCell!.isHidden = true
        }
        
        // Setup the myTBASwitch (on/off) depending on if the user enabled myTBA or not
    }
    
    // MARK: - IBActions
    @IBAction private func doneButtonTaped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
  
    @IBAction func myTBASwitchTaped(_ sender: UISwitch) {
        
        if sender.isOn {
            // Enable myTBA feature
        } else {
            // Disable myTBA + show some kind of alert to tell the user which features they won't be able to use by doing so ...
        }
        
    }
    
    // MARK: - Table view configuration
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         if indexPath.section == 2 {
            var urlString: String?
            
            tableView.deselectRow(at: indexPath, animated: true)
            switch indexPath.row {
                
            case 0:
                urlString = "https://www.thebluealliance.com"
                
            case 1:
                urlString = "https://github.com/the-blue-alliance/the-blue-alliance-ios"
                
            case 2:
                break
                
            case 3:
                break
                
            case 4:
                break
                
            case 5:
                break
                
            // We shouldn't hit this case
            default:
                fatalError("This row does not seem to exist")
                
            }
            
            if let urlString = urlString {
                let url = URL(string: urlString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        } else if indexPath.section == 3 {
            let alertController = UIAlertController(title: "Delete network cache", message: "", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let disableAction = UIAlertAction(title: "Delete", style: .destructive) { (disableAction) in
                // Implement the network cache deletion feature ...
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(disableAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
}
