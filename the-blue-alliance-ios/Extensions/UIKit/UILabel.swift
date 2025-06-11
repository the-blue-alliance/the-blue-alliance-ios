//
//  UILabel+TBA.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/21/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

extension UILabel {

    private class func label(forTextStyle style: UIFont.TextStyle) -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: style)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }

    class func headlineLabel() -> UILabel {
        return UILabel.label(forTextStyle: .headline)
    }

    /// Body tea, face card never declines
    class func bodyLabel() -> UILabel {
        return UILabel.label(forTextStyle: .body)
    }

    class func subheadlineLabel() -> UILabel {
        return UILabel.label(forTextStyle: .subheadline)
    }

    class func caption2Label() -> UILabel {
        return UILabel.label(forTextStyle: .caption2)
    }

}
