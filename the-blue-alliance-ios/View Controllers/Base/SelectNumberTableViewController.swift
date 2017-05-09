//
//  SelectTableViewController.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/8/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit

class SelectTableViewController<T: Comparable>: UITableViewController {

    // TODO: Use UserDefaults to set currentYear as well
    var current: T?
    var options: [T]?
    var optionSelected: ((_ option: T) -> (Swift.Void))?
    var optionString: ((_ option: T) -> (String)) = { t in return "" }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissModal(_:)))
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let option = options![indexPath.row]
        if let current = current, option == current {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        cell.textLabel?.text = optionString(option)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        let option = options![indexPath.row]
        if let optionSelected = optionSelected, option != current {
            optionSelected(option)
        }

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissModal(_ sender: UIBarButtonItem) {
       dismiss(animated: true, completion: nil)
    }
}
