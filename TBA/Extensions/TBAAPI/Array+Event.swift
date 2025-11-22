//
//  Array+Event.swift
//  TBA
//
//  Created by Zachary Orr on 5/3/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI

/// SeasonEvent describes an Event we know how to parse a EventWeek for.
struct SeasonEvent {
    var event: Event
    var eventWeek: EventWeek

    init?(_ event: Event) {
        self.event = event
        guard let eventWeek = event.eventWeek else {
            return nil
        }
        self.eventWeek = eventWeek
    }
}

extension [SeasonEvent] {
    /// Returns the next upcoming event or the earliest event in the list.
    func nextOrFirstEvent() -> SeasonEvent? {
        // First, sort all of our events. Events are first sorted by start date. If the start date
        // for two events is the same, sort by the end date.
        let sortedSeasonEvents = sorted { lhs, rhs in
            if lhs.event.startDate != rhs.event.startDate {
                return lhs.event.startDate < rhs.event.startDate
            }
            return lhs.event.endDate < rhs.event.endDate
        }
        let today = Date()
        return sortedSeasonEvents.first { seasonEvent in
            // Look to find the first event in our sorted event list that the endDate is
            // either before today or is today.
            Calendar.current.compare(today, to: seasonEvent.event.endDate, toGranularity: .day) == .orderedAscending || Calendar.current.compare(today, to: seasonEvent.event.endDate, toGranularity: .day) == .orderedSame
        } ?? sortedSeasonEvents.first
    }

    private var sortedCMPKeys: [EventKey] {
        filter(\.event.isCMPFinals).sorted { $0.event.startDate < $1.event.startDate }.map(\.event.key)
    }

    func groupedByWeek() -> [EventWeek: [SeasonEvent]] {
        // TODO: I THINK this is where we'd shim our 2020 event logic code.
        // TODO: Also, possibly to drop the participation events?
        let sortedCMPKeys = sortedCMPKeys
        // If it's a year with a single CMP - we can let our CMP events all be grouped into the same week
        guard sortedCMPKeys.count > 1 else {
            return Dictionary(grouping: self, by: { $0.eventWeek })
        }
        // Otherwise, modify our CMP EventWeek to be sorted
        return Dictionary(grouping: self) { seasonEvent in
            // Make sure our CMP Divisions + CMP Finals all get into the same EventWeek grouping
            if seasonEvent.event.isChampionshipEvent {
                let cmpKey = seasonEvent.event.parentEventKey ?? seasonEvent.event.key
                if let cmpIndex = sortedCMPKeys.firstIndex(of: cmpKey) {
                    return seasonEvent.event.eventWeek(cmpIndex: cmpIndex) ?? seasonEvent.eventWeek
                }
            }
            return seasonEvent.eventWeek
        }
    }
}
