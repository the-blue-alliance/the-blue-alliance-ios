//
//  EventItemView.swift
//  TBA
//
//  Created by Zachary Orr on 11/17/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI

struct EventItemView: View {
    let title: String

    var body: some View {
        VStack {
            Spacer()
            NavigationLink {
                Text(title)
            } label: {
                HStack(spacing: 0) {
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .tint(.secondary)
                        .foregroundStyle(.secondary)
                }
                // TODO: Maybe padding instead of minHeight?
                // .frame(minHeight: 44.0)
            }
            .padding(.trailing)
            Divider()
        }
        .padding(.leading)
    }
}
