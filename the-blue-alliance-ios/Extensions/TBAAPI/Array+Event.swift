//
//  Array+Event.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 5/3/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI

// Represents an Event we know how to support
struct SeasonEvent {
    var event: Event
    var eventWeek: EventWeek

    init?(event: Event) {
        self.event = event
        guard let eventWeek = event.eventWeek else {
            return nil
        }
        self.eventWeek = eventWeek
    }
}

extension Array where Element == SeasonEvent {

    func nextOrFirstEvent() -> SeasonEvent? {
        let today = Date()
        let sortedSeasonEvents = self.sorted(using: [KeyPathComparator(\.event.startDate), KeyPathComparator(\.event.endDate)])
        let firstSeasonEvent = sortedSeasonEvents.first
        guard firstSeasonEvent?.event.year == Calendar.current.component(.year, from: today) else {
            return firstSeasonEvent
        }
        return sortedSeasonEvents.first { seasonEvent in
            // TODO: Probably a bug here with endDate not working properly on same day
            return Calendar.current.compare(today, to: seasonEvent.event.endDate, toGranularity: .day) == .orderedAscending
        } ?? firstSeasonEvent
    }

    private var sortedCMPKeys: [EventKey] {
        return self.filter(\.event.isCMPFinals).sorted(using: KeyPathComparator(\.event.startDate)).map(\.event.key)
    }

    func groupedByWeek() -> [EventWeek: [SeasonEvent]] {
        let sortedCMPKeys = sortedCMPKeys
        guard sortedCMPKeys.count > 1 else {
            return Dictionary(grouping: self, by: { $0.eventWeek })
        }
        return Dictionary(grouping: self) { seasonEvent in
            if let cmpIndex = sortedCMPKeys.firstIndex(of: seasonEvent.event.key) {
                return seasonEvent.event.eventWeek(cmpIndex: cmpIndex)!
            }
            return seasonEvent.eventWeek
        }
    }
}
