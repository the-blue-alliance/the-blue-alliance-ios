import CoreData
import Foundation
import TBAAPI
import TBAKit
import TBAUtils

class Dependencies {
    let errorRecorder: ErrorRecorder
    let persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit
    let api: TBAAPI
    let userDefaults: UserDefaults

    init(errorRecorder: ErrorRecorder,
         persistentContainer: NSPersistentContainer,
         tbaKit: TBAKit,
         api: TBAAPI,
         userDefaults: UserDefaults) {
        self.errorRecorder = errorRecorder
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.api = api
        self.userDefaults = userDefaults
    }
}
