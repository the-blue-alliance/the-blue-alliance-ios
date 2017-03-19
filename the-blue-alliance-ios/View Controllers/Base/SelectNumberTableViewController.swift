//
//  SelectNumberTableViewController.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/8/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit

enum SelectNumberType {
    case year
    case week
}

class SelectNumberTableViewController: UITableViewController {

    // TODO: Use UserDefaults to set currentYear as well
    var currentNumber: Int?
    var numbers: [Int]?
    var selectNumberType: SelectNumberType?
    var numberSelected: ((_ number: Int) -> (Swift.Void))?
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberCell", for: indexPath)

        let number = numbers![indexPath.row]
        if number == currentNumber {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = String(number)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        let number = numbers![indexPath.row]
        if let numberSelected = numberSelected {
            numberSelected(number)
        }

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissModal(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
    }
}
