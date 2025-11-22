//
//  Date+TBA.swift
//  TBA
//
//  Created by Zachary Orr on 11/22/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM"
    return dateFormatter
}()

extension Date {
    var month: String {
        dateFormatter.string(from: self)
    }
}
