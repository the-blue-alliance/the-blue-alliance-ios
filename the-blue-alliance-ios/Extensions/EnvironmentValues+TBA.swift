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
    @Entry var api: TBAAPI = TBAAPI(apiKey: Secrets().tbaAPIKey)
    @Entry var status: Status = Status(
        currentSeason: Calendar.current.year,
        maxSeason: Calendar.current.year,
        isDatafeedDown: false,
        downEvents: [],
        ios: Status.AppInfo(
            minAppVersion: -1,
            latestAppVersion: -1
        ),
        android: Status.AppInfo(
            minAppVersion: -1,
            latestAppVersion: -1
        ),
        maxTeamPage: 0
    )
}
