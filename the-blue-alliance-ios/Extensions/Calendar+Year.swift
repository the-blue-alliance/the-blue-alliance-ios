import Foundation

extension Calendar {

    var year: Int {
        get {
            return self.component(.year, from: Date())
        }
    }

}
