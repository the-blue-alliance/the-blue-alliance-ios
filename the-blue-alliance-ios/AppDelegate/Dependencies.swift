import Foundation
import TBAAPI
import TBAUtils

class Dependencies {
    let errorRecorder: ErrorRecorder
    let api: TBAAPI
    let userDefaults: UserDefaults

    init(errorRecorder: ErrorRecorder,
         api: TBAAPI,
         userDefaults: UserDefaults) {
        self.errorRecorder = errorRecorder
        self.api = api
        self.userDefaults = userDefaults
    }
}
