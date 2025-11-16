//
//  Calendar+Year.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation

extension Calendar {
    var year: Int {
        return Calendar.current.component(.year, from: Date())
    }
}
