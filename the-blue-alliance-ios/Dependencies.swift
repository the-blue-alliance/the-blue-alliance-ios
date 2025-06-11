//
//  Dependencies.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/24/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import TBAAPI

@MainActor protocol DependencyProvider: AnyObject {
    var api: TBAAPI { get }
    var searchService: SearchService { get }
    var statusService: StatusService { get }
}
