//
//  Array+Event.swift
//  TBAModels
//
//  Created by Zachary Orr on 4/19/25.
//

/*
import Foundation
import TBAUtils

extension Array where Element == Event {
    private var sortedCMPKeys: [EventKey] {
        return self.filter(\.isCMPFinals).sorted(using: KeyPathComparator(\.startDate)).map(\.key)
    }

    public func nextOrFirstEvent() -> Event? {
        let sortedEvents = self.sorted(using: [KeyPathComparator(\.startDate), KeyPathComparator(\.endDate)])
        let firstEvent = sortedEvents.first
        guard firstEvent?.year == Calendar.current.year else {
            return firstEvent
        }
        return sortedEvents.first { event in
            event.endDate > Date().startOfDay()
        } ?? firstEvent
    }

    public func groupedByWeek() -> [EventWeek: [Event]] {
        let sortedCMPKeys = sortedCMPKeys
        guard sortedCMPKeys.count > 1 else {
            return self.grouped(by: { $0.eventWeek })
        }
        return self.grouped { event in
            if let cmpIndex = sortedCMPKeys.firstIndex(of: event.key) {
                return event.eventWeek(cmpIndex: cmpIndex)
            }
            return event.eventWeek
        }
    }
}
*/
