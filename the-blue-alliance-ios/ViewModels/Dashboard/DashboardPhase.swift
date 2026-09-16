import Foundation
import TBAAPI

nonisolated enum DashboardPhase: Hashable {
    /// The season has ended and the next kickoff is not close enough to count down to.
    case offseason(season: Int)
    /// Inside the countdown window the website uses: Nov 1 through kickoff.
    case preKickoff(season: Int, kickoff: Date)
    /// Kickoff day, through the day after.
    case kickoff(season: Int, kickoff: Date)
    /// After kickoff, before the first regional or district event.
    case buildSeason(season: Int, firstEventStart: Date?)
    case competition(season: Int, week: Int, weekLabel: String, totalWeeks: Int)
    case championship(season: Int)

    var season: Int {
        switch self {
        case .offseason(let season), .preKickoff(let season, _), .kickoff(let season, _),
            .buildSeason(let season, _), .competition(let season, _, _, _),
            .championship(let season):
            return season
        }
    }

    struct Input {
        var now: Date
        var currentSeason: Int
        var maxSeason: Int
        /// `kickoff_datetime` from `/status`, which the server computes for the upcoming season.
        var kickoff: Date?
        var currentSeasonEvents: [Event]
        /// Events for `maxSeason` when it's past `currentSeason`; empty otherwise.
        var nextSeasonEvents: [Event] = []
        var calendar: Calendar = .current
    }

    static func resolve(_ input: Input) -> DashboardPhase {
        let season = input.currentSeason
        let events = input.currentSeasonEvents
        let now = input.now

        if events.contains(where: { $0.isChampionshipEvent && isLive($0, at: now) }) {
            return .championship(season: season)
        }

        let inSeason = events.filter(\.isInSeason)
        let seasonStart = inSeason.compactMap(\.startDateParsed).min()
        let seasonEnd = Self.seasonEnd(of: events)

        if let seasonEnd, now > seasonEnd {
            let next = season + 1
            return phaseBefore(
                season: next,
                kickoff: kickoff(for: next, input: input),
                firstEventStart: input.nextSeasonEvents.filter(\.isInSeason)
                    .compactMap(\.startDateParsed).min(),
                input: input
            )
        }

        if let seasonStart, now >= seasonStart {
            return competition(
                season: season,
                events: inSeason.filter {
                    ($0.endOfEventDay ?? .distantPast) <= (seasonEnd ?? .distantFuture)
                },
                now: now,
                calendar: input.calendar
            )
        }

        return phaseBefore(
            season: season,
            kickoff: kickoff(for: season, input: input),
            firstEventStart: seasonStart,
            input: input
        )
    }

    // MARK: - Helpers

    private static func phaseBefore(
        season: Int,
        kickoff: Date?,
        firstEventStart: Date?,
        input: Input
    ) -> DashboardPhase {
        // No kickoff means the server hasn't started listing that season yet.
        guard let kickoff else {
            return .offseason(season: season - 1)
        }
        let now = input.now
        var eastern = Calendar(identifier: .gregorian)
        eastern.timeZone = Kickoff.timeZone
        // The website opens the countdown on Nov 1 and closes it a day after kickoff.
        let windowStart = eastern.date(from: DateComponents(year: season - 1, month: 11, day: 1))!
        let windowEnd = eastern.date(byAdding: .day, value: 1, to: kickoff)!

        if now < windowStart {
            return .offseason(season: season - 1)
        }
        if now < kickoff {
            return .preKickoff(season: season, kickoff: kickoff)
        }
        if now <= windowEnd {
            return .kickoff(season: season, kickoff: kickoff)
        }
        return .buildSeason(season: season, firstEventStart: firstEventStart)
    }

    // Prefer the server's date when it's for the season being asked about; otherwise estimate
    // locally, but only once the server has started listing that season.
    private static func kickoff(for season: Int, input: Input) -> Date? {
        if let kickoff = input.kickoff,
            Calendar(identifier: .gregorian).component(.year, from: kickoff) == season
        {
            return kickoff
        }
        guard input.maxSeason >= season else { return nil }
        return Kickoff.date(for: season)
    }

    private static func competition(
        season: Int,
        events: [Event],
        now: Date,
        calendar: Calendar
    ) -> DashboardPhase {
        let totalWeeks = (events.compactMap(\.week).max() ?? 0) + 1
        let today = calendar.startOfDay(for: now)
        // Same rule the Events tab uses to land on "this week": the first event that hasn't
        // finished by the user's local day.
        let current =
            events
            .filter { !$0.isChampionshipDivision }
            .filter { ($0.endOfEventDay ?? .distantPast) >= today }
            .min { ($0.endDateParsed ?? .distantPast) < ($1.endDateParsed ?? .distantPast) }
        let week = current?.week ?? max(totalWeeks - 1, 0)
        let label = current?.weekString ?? "Week \(week + 1)"
        return .competition(season: season, week: week, weekLabel: label, totalWeeks: totalWeeks)
    }

    // Championship finals end the season; late outliers (Israel ran districts in July 2026)
    // don't extend it. Seasons without a Championship end with their last in-season event.
    private static func seasonEnd(of events: [Event]) -> Date? {
        let finals = events.filter(\.isChampionshipFinals).compactMap(\.endOfEventDay)
        if let end = finals.max() {
            return end
        }
        return events.filter(\.isInSeason).compactMap(\.endOfEventDay).max()
    }

    private static func isLive(_ event: Event, at now: Date) -> Bool {
        guard let start = event.startDateParsed, let end = event.endOfEventDay else {
            return false
        }
        return now >= start && now <= end
    }

}

nonisolated extension Event {
    /// Regionals, districts, and district championships: the events that define season weeks.
    fileprivate var isInSeason: Bool {
        isRegional || eventTypeEnum == .district || isDistrictChampionshipEvent
    }
}
