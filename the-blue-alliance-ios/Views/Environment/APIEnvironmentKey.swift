//
//  APIEnvironmentKey.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 5/3/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

private struct APIEnvironmentKey: EnvironmentKey {
    static let defaultValue: TBAAPI = TBAAPI(apiKey: "")
}

extension EnvironmentValues {
    var api: TBAAPI {
        get { self[APIEnvironmentKey.self] }
        set { self[APIEnvironmentKey.self] = newValue }
    }
}

extension Scene {
    @discardableResult
    func api(api: TBAAPI) -> some Scene {
        self
            .environment(\.api, api)
    }
}

extension View {
    @discardableResult
    func api(api: TBAAPI) -> some View {
        self
            .environment(\.api, api)
    }
}
