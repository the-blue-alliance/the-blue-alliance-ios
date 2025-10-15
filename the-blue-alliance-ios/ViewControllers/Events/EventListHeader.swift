//
//  EventListHeader.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI

struct EventListHeader: View {

    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.leading)
                .padding([.top, .bottom], 5)
            Spacer()
        }
        .background(Color(UIColor.tableViewHeaderColor))
    }

}
