//
//  EnvironmentValues+TBA.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 10/15/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

extension EnvironmentValues {
    @Entry var secrets: Secrets = Secrets()
    @Entry var api: TBAAPI = TBAAPI(apiKey: Secrets().tbaAPIKey)
}
