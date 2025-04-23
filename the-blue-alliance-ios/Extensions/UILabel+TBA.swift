//
//  UILabel+TBA.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/21/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

extension UILabel {

    private class func label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    /// Body tea, face card never declines
    class func bodyLabel() -> UILabel {
        let label = UILabel.label()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }

    class func subheadlineLabel(textColor: UIColor = .secondaryLabel) -> UILabel {
        let label = UILabel.label()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = textColor
        return label
    }

}
