import CoreData
import Foundation
import TBAKit
import TBAUtils

class Dependencies {
    let errorRecorder: ErrorRecorder
    let persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit
    let userDefaults: UserDefaults

    init(errorRecorder: ErrorRecorder, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.errorRecorder = errorRecorder
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults
    }
}
