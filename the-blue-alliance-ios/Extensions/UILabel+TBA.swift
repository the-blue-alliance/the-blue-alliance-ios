//
//  UILabel+TBA.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/21/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

extension UILabel {

    static func subheadlineLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }

}
