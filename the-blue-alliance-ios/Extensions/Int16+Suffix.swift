import Foundation

extension Int {

    var suffix: String {
        let positive = abs(self)

        let lastTwo = positive % 100
        let lastOne = lastTwo % 10

        if 11 ... 20 ~= lastTwo {
            return "th"
        } else if lastOne == 1 {
            return "st"
        } else if lastOne == 2 {
            return "nd"
        } else if lastOne == 3 {
            return "rd"
        } else {
            return "th"
        }
    }

}
