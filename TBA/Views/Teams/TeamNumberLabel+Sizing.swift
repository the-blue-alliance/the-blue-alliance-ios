//
//  TeamNumberLabel+Sizing.swift
//  TBA
//
//  Created by Zachary Orr on 4/25/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

let kMaxNumberOfTeamDigits = 5

import Foundation
import UIKit

extension UIFont {

    @MainActor
    func widthForTeamMaxTeamNumber() -> CGFloat {
        // 8 is the widest number in SF Pro
        let maxNumberString = String(repeating: "8", count: kMaxNumberOfTeamDigits)
        // Calculate the required width for the text
        let boundingBox = maxNumberString.boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: self],
            context: nil
        )
        return ceil(boundingBox.width)
    }

}
