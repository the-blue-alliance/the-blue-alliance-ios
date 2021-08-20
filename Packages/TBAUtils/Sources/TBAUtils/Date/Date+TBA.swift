import Foundation

extension Date {

    public var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    /**
     Determines if the reciver is between two given dates.
     */
    public func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }

    public func startOfMonth(calendar: Calendar = Calendar.current) -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }

    public func endOfMonth(calendar: Calendar = Calendar.current) -> Date {
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }

    /**
     00:00:00am on the reciving date.
     */
    public func startOfDay(calendar: Calendar = Calendar.current) -> Date {
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }

    /**
     11:59:59pm on the reciving date - used to inclusively match date in date logic
     */
    public func endOfDay(calendar: Calendar = Calendar.current) -> Date {
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }

    /**
     Find the next weekday after the current date.

     This method is not inclusive of the reciever. Ex: If reciever is a Monday, and we're looking for the next Monday, it will return reciever + 7, not reciever
     */
    public func next(_ weekday: Weekday, calendar: Calendar = Calendar.current) -> Date {
        return calendar.nextDate(after: self, matching: DateComponents(weekday: weekday.rawValue), matchingPolicy: .strict)!
    }

}
