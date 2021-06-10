//
//  PadRootViewHostingController.swift
//  The Blue Alliance
//
//  Created by Zachary Orr on 6/10/21.
//  Copyright © 2021 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAData
import MyTBAKit
import Photos
import SwiftUI
import UIKit

class PadRootViewHostingController: UIHostingController<PadRootView>, RootController {

    var fcmTokenProvider: FCMTokenProvider
    var myTBA: MyTBA
    var pasteboard: UIPasteboard?
    var photoLibrary: PHPhotoLibrary?
    var pushService: PushService
    var searchService: SearchService
    var urlOpener: URLOpener
    var statusService: StatusService
    var dependencies: Dependencies

    init(fcmTokenProvider: FCMTokenProvider, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, pushService: PushService, searchService: SearchService, urlOpener: URLOpener, statusService: StatusService, dependencies: Dependencies) {
        self.fcmTokenProvider = fcmTokenProvider
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.pushService = pushService
        self.searchService = searchService
        self.urlOpener = urlOpener
        self.statusService = statusService
        self.dependencies = dependencies

        super.init(rootView: PadRootView())
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func continueSearch(_ searchText: String) -> Bool {
        // TODO: Implement
        return true
    }

    func show(event: Event) -> Bool {
        // TODO: Implement
        return true
    }

    func show(team: Team) -> Bool {
        // TODO: Implement
        return true
    }

}
