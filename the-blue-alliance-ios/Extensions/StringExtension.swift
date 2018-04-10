//
//  StringExtension.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/18/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation

extension String {
    
    func prefixTrim(_ prefix: String) -> String {
        if let index = self.characters.index(where: {!prefix.characters.contains($0)}) {
            return String(self[index..<self.endIndex])
        } else {
            return self
        }
    }
    
}
