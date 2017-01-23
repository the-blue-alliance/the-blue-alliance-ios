//
//  EventViewController.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/7/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {

    public var event: Event!
    
    @IBOutlet internal var infoView: UIView?
    @IBOutlet internal var teamsView: UIView?
    @IBOutlet internal var rankingsView: UIView?
    @IBOutlet internal var matchesView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventInfoEmbed" {
            let infoViewController = segue.destination as! EventInfoTableViewController
            infoViewController.event = event
        }
    }

}
