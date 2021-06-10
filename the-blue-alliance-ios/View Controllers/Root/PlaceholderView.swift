//
//  PlaceholderView.swift
//  The Blue Alliance
//
//  Created by Zachary Orr on 6/10/21.
//  Copyright © 2021 The Blue Alliance. All rights reserved.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        if #available(iOS 15.0, *) {
            Image("lamp")
                .renderingMode(.template)
                .foregroundColor(Color(uiColor: UIColor.quaternarySystemFill))
        } else {
            Image("lamp")
        }
    }
}
