//
//  EventView.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import TBAAPI
import SwiftUI

struct EventView: View {

    var event: Event

    var body: some View {
        Text(event.name)
    }

}
