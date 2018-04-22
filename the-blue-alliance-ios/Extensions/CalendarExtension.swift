//
//  CalendarExtension.swift
//  the-blue-alliance
//
//  Created by Zach Orr on 1/8/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation

extension Calendar {
    
    var year: Int {
        get {
            return self.component(.year, from: Date())
        }
    }
    
}
