import Foundation

extension Date {

    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }

    func startOfMonth(calendar: Calendar = Calendar.current) -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
    }

    func endOfMonth(calendar: Calendar = Calendar.current) -> Date {
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }

}
