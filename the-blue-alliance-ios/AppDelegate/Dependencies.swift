import Foundation
import MyTBAKit
import TBAAPI
import TBAUtils
import UIKit

class Dependencies {
    let api: any TBAAPIProtocol
    let appSettings: AppSettings
    let myTBA: any MyTBAProtocol
    let myTBAStores: MyTBAStores
    let reporter: any Reporter
    let statusService: any StatusServiceProtocol
    let urlOpener: any URLOpener

    init(
        api: any TBAAPIProtocol,
        appSettings: AppSettings,
        myTBA: any MyTBAProtocol,
        myTBAStores: MyTBAStores,
        reporter: any Reporter,
        statusService: any StatusServiceProtocol,
        urlOpener: any URLOpener = UIApplication.shared
    ) {
        self.api = api
        self.appSettings = appSettings
        self.myTBA = myTBA
        self.myTBAStores = myTBAStores
        self.reporter = reporter
        self.statusService = statusService
        self.urlOpener = urlOpener
    }
}
