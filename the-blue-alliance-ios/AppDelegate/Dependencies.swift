import CoreData
import Foundation
import TBAKit
import TBAUtils
import TBAAPI

class Dependencies {
    let api: TBAAPI
    let errorRecorder: ErrorRecorder
    let persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit
    let userDefaults: UserDefaults

    init(api: TBAAPI, errorRecorder: ErrorRecorder, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.api = api
        self.errorRecorder = errorRecorder
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults
    }
}
