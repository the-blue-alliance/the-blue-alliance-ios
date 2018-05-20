//
//  SwitchTableViewCell.swift
//  The Blue Alliance
//
//  Created by Anas Merbouh on 18-05-20.
//  Copyright © 2018 The Blue Alliance. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var switchToggle: UISwitch!
    
    public final func populate(withTitle title: String) {
        titleLabel.text = title
    }
    
}
