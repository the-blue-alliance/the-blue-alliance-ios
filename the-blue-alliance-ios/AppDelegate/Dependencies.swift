import Foundation
import MyTBAKit
import TBAAuth
import TBAAPI
import TBAUtils
import UIKit

class Dependencies {
    let api: any TBAAPIProtocol
    let appSettings: AppSettings
    let authService: any AuthServiceProtocol
    let myTBA: any MyTBAProtocol
    let myTBAStores: MyTBAStores
    let myTBASession: MyTBASessionService
    let reporter: any Reporter
    let statusService: any StatusServiceProtocol
    let urlOpener: any URLOpener

    init(
        api: any TBAAPIProtocol,
        appSettings: AppSettings,
        authService: any AuthServiceProtocol,
        myTBA: any MyTBAProtocol,
        myTBAStores: MyTBAStores,
        myTBASession: MyTBASessionService,
        reporter: any Reporter,
        statusService: any StatusServiceProtocol,
        urlOpener: any URLOpener = UIApplication.shared
    ) {
        self.api = api
        self.appSettings = appSettings
        self.authService = authService
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.myTBASession = myTBASession
        self.reporter = reporter
        self.statusService = statusService
        self.urlOpener = urlOpener
    }
}

protocol DependenciesProviding: AnyObject {
    var dependencies: Dependencies { get }
}

extension DependenciesProviding {
    var api: any TBAAPIProtocol { dependencies.api }
    var myTBA: any MyTBAProtocol { dependencies.myTBA }
    var myTBAStores: MyTBAStores { dependencies.myTBAStores }
    var statusService: any StatusServiceProtocol { dependencies.statusService }
    var urlOpener: any URLOpener { dependencies.urlOpener }
}
