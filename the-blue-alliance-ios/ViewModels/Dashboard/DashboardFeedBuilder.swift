import Foundation
import TBAAPI

/// Every fetch is best-effort: a failed request drops its card, never the feed.
nonisolated struct DashboardFeedBuilder {

    struct Follows {
        var teamKeys: [String] = []
        var eventKeys: [String] = []

        var isEmpty: Bool { teamKeys.isEmpty && eventKeys.isEmpty }
    }

    struct Context {
        var phase: DashboardPhase
        /// Events for `phase.season`.
        var seasonEvents: [Event]
        var isSignedIn: Bool
        var now: Date = Date()
        var calendar: Calendar = .current
    }

    static let upcomingWindow: TimeInterval = 14 * 24 * 60 * 60
    static let recentWindow: TimeInterval = 48 * 60 * 60
    static let topRankings = 8

    let api: any TBAAPIProtocol

    // MARK: - Loading

    func load(
        follows: Follows,
        status: AppStatus,
        isSignedIn: Bool,
        now: Date = Date(),
        calendar: Calendar = .current
    ) async -> (phase: DashboardPhase, cards: [DashboardCard]) {
        let currentSeason = status.currentSeason
        let currentEvents = (try? await api.eventsByYear(currentSeason)) ?? []
        let nextEvents: [Event] =
            status.maxSeason > currentSeason
            ? (try? await api.eventsByYear(status.maxSeason)) ?? [] : []

        let phase = DashboardPhase.resolve(
            .init(
                now: now,
                currentSeason: currentSeason,
                maxSeason: status.maxSeason,
                kickoff: status.kickoffDate,
                currentSeasonEvents: currentEvents,
                nextSeasonEvents: nextEvents,
                calendar: calendar
            )
        )
        let seasonEvents = phase.season == currentSeason ? currentEvents : nextEvents
        let cards = await build(
            follows: follows,
            context: Context(
                phase: phase,
                seasonEvents: seasonEvents,
                isSignedIn: isSignedIn,
                now: now,
                calendar: calendar
            )
        )
        return (phase, cards)
    }

    func build(follows: Follows, context: Context) async -> [DashboardCard] {
        // Unstructured handles rather than a task group or async let: see #996.
        let teamHandles = follows.teamKeys.map { teamKey in
            Task { await teamSection(teamKey: teamKey, context: context) }
        }
        let followedTeamKeys = Set(follows.teamKeys)
        let eventHandles = follows.eventKeys.map { eventKey in
            Task {
                await eventSection(
                    eventKey: eventKey,
                    followedTeamKeys: followedTeamKeys,
                    context: context
                )
            }
        }

        var heroes: [TeamAtEventCard] = []
        var upNext: [UpNextCard.Entry] = []
        var recent: [RecentResultsCard.Entry] = []
        for handle in teamHandles {
            guard let section = await handle.value else { continue }
            if let hero = section.hero { heroes.append(hero) }
            upNext.append(contentsOf: section.upNext)
            recent.append(contentsOf: section.recent)
        }

        var liveEvents: [EventLiveCard] = []
        for handle in eventHandles {
            guard let section = await handle.value else { continue }
            if let live = section.live { liveEvents.append(live) }
            if let entry = section.upNext { upNext.append(entry) }
        }

        var cards: [DashboardCard] = []
        cards += heroes.sorted(by: heroOrder).map(DashboardCard.teamAtEvent)
        cards += liveEvents.sorted(by: { startOrder($0.event, $1.event) })
            .map(DashboardCard.followedEventLive)
        if !upNext.isEmpty {
            cards.append(
                .upNext(UpNextCard(entries: upNext.sorted { startOrder($0.event, $1.event) }))
            )
        }
        if !recent.isEmpty {
            let sorted = recent.sorted { ($0.match.time ?? 0) > ($1.match.time ?? 0) }
            cards.append(.recentResults(RecentResultsCard(entries: sorted)))
        }
        let thisWeek = Self.eventsThisWeek(
            in: context.seasonEvents,
            now: context.now,
            calendar: context.calendar
        )
        if !thisWeek.isEmpty {
            cards.append(.thisWeekEvents(ThisWeekEventsCard(events: thisWeek)))
        }
        cards.append(.season(context.phase))
        if follows.isEmpty {
            cards.append(.getStarted(signedIn: context.isSignedIn))
        }
        return cards
    }

    // MARK: - Followed teams

    private struct TeamSection {
        var hero: TeamAtEventCard?
        var upNext: [UpNextCard.Entry] = []
        var recent: [RecentResultsCard.Entry] = []
    }

    private func teamSection(teamKey: String, context: Context) async -> TeamSection? {
        guard let team = try? await api.team(key: teamKey),
            let events = try? await api.teamEventsByYear(key: teamKey, year: context.phase.season)
        else { return nil }

        var section = TeamSection()
        let now = context.now

        if let live = Self.liveEvent(in: events, now: now) {
            let status = try? await api.teamEventStatus(teamKey: teamKey, eventKey: live.key)
            let media = try? await api.teamMediaByYear(teamKey: teamKey, year: context.phase.season)
            section.hero = TeamAtEventCard(
                team: team,
                event: live,
                status: status,
                nextMatch: await match(key: status?.nextMatchKey),
                lastMatch: await match(key: status?.lastMatchKey),
                avatarBase64: media?.first { $0.type == .avatar }?.avatarBase64Image
            )
        } else {
            for event in events where Self.endedRecently(event, now: now) {
                guard
                    let status = try? await api.teamEventStatus(
                        teamKey: teamKey,
                        eventKey: event.key
                    ),
                    let last = await match(key: status.lastMatchKey)
                else { continue }
                section.recent.append(.init(team: team, event: event, match: last))
            }
        }

        section.upNext = events.filter { Self.isUpcoming($0, now: now) }
            .map { UpNextCard.Entry(team: team, event: $0) }
        return section
    }

    private func match(key: String?) async -> Match? {
        guard let key else { return nil }
        return try? await api.match(key: key)
    }

    // MARK: - Followed events

    private struct EventSection {
        var live: EventLiveCard?
        var upNext: UpNextCard.Entry?
    }

    private func eventSection(
        eventKey: String,
        followedTeamKeys: Set<String>,
        context: Context
    ) async -> EventSection? {
        guard let event = try? await api.event(key: eventKey) else { return nil }
        var section = EventSection()

        if Self.isLive(event, now: context.now) {
            let rankings = (try? await api.eventRankings(key: eventKey))?.rankings ?? []
            let alliances = (try? await api.eventAlliances(key: eventKey)) ?? nil
            section.live = EventLiveCard(
                event: event,
                rankings: Self.highlightRankings(rankings, followedTeamKeys: followedTeamKeys),
                followedTeamKeys: followedTeamKeys,
                alliances: alliances
            )
        } else if Self.isUpcoming(event, now: context.now) {
            section.upNext = UpNextCard.Entry(team: nil, event: event)
        }
        return section
    }

    /// The top of the table plus any followed team's row, in rank order.
    static func highlightRankings(
        _ rankings: [EventRanking.RankingsPayloadPayload],
        followedTeamKeys: Set<String>
    ) -> [EventRanking.RankingsPayloadPayload] {
        let sorted = rankings.sorted { $0.rank < $1.rank }
        var kept = Array(sorted.prefix(topRankings))
        kept += sorted.dropFirst(topRankings).filter { followedTeamKeys.contains($0.teamKey) }
        return kept
    }

    // MARK: - Ordering

    private func heroOrder(_ lhs: TeamAtEventCard, _ rhs: TeamAtEventCard) -> Bool {
        let l = lhs.nextMatch?.startTime ?? .max
        let r = rhs.nextMatch?.startTime ?? .max
        if l != r { return l < r }
        return lhs.team.teamNumber < rhs.team.teamNumber
    }

    private func startOrder(_ lhs: Event, _ rhs: Event) -> Bool {
        let l = lhs.startDateParsed ?? .distantFuture
        let r = rhs.startDateParsed ?? .distantFuture
        if l != r { return l < r }
        return lhs.key < rhs.key
    }

    // MARK: - Date rules

    static func isLive(_ event: Event, now: Date) -> Bool {
        guard let start = event.startDateParsed, let end = event.endOfEventDay else { return false }
        return now >= start && now <= end
    }

    static func isUpcoming(_ event: Event, now: Date) -> Bool {
        guard let start = event.startDateParsed else { return false }
        return start > now && start <= now.addingTimeInterval(upcomingWindow)
    }

    static func endedRecently(_ event: Event, now: Date) -> Bool {
        guard let end = event.endOfEventDay else { return false }
        return end < now && end >= now.addingTimeInterval(-recentWindow)
    }

    // A team's Championship division and the finals event overlap; the division is where
    // its matches are.
    static func liveEvent(in events: [Event], now: Date) -> Event? {
        events.filter { isLive($0, now: now) }
            .min { lhs, rhs in
                if lhs.isChampionshipFinals != rhs.isChampionshipFinals {
                    return !lhs.isChampionshipFinals
                }
                return (lhs.startDateParsed ?? .distantPast) < (rhs.startDateParsed ?? .distantPast)
            }
    }

    // Same window as the website's home page: the user's Monday-through-Sunday week.
    static func eventsThisWeek(in events: [Event], now: Date, calendar: Calendar) -> [Event] {
        var weekCalendar = calendar
        weekCalendar.firstWeekday = 2
        guard let week = weekCalendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
        return
            events
            .filter { event in
                guard let start = event.startDateParsed, let end = event.endOfEventDay else {
                    return false
                }
                return start < week.end && end >= week.start
            }
            .sorted { lhs, rhs in
                let l = lhs.startDateParsed ?? .distantFuture
                let r = rhs.startDateParsed ?? .distantFuture
                if l != r { return l < r }
                return lhs.safeShortName.localizedCaseInsensitiveCompare(rhs.safeShortName)
                    == .orderedAscending
            }
    }

}
