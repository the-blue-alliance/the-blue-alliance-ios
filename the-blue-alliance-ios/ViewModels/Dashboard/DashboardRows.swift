import Foundation
import TBAAPI
import TBAUtils

nonisolated enum DashboardAction: Hashable {
    case teamAtEvent(teamKey: String, eventKey: EventKey)
    case event(Event)
    case match(Match, teamKey: String?)
    case tab(RootType)
}

/// A row inside a card: a title with either a subtitle beneath it or a bold value beside it.
nonisolated struct DashboardRow: Hashable {
    let id: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var isEmphasized = false
    var action: DashboardAction? = nil
}

/// Lays the feed out as focused sections: a summary first, then one titled card per topic.
enum DashboardRows {

    static func sections(for cards: [DashboardCard], now: Date) -> [(
        DashboardSection, [DashboardItem]
    )] {
        var seasonItems: [DashboardItem] = []
        var weekItems: [DashboardItem] = []
        var sections: [(DashboardSection, [DashboardItem])] = []
        var hasTitledHero = false

        for card in cards {
            let (section, items) = rows(for: card, now: now)
            switch card {
            case .season:
                seasonItems = items
            case .thisWeekEvents:
                weekItems = items
            case .teamAtEvent:
                // One "Competing now" title covers every followed team at an event.
                let title = hasTitledHero ? nil : section.title
                hasTitledHero = true
                sections.append((DashboardSection(id: section.id, title: title), items))
            default:
                sections.append((section, items))
            }
        }

        let summary = seasonItems + weekItems
        if !summary.isEmpty {
            sections.insert((DashboardSection(id: "summary", title: nil), summary), at: 0)
        }
        return sections
    }

    static func rows(for card: DashboardCard, now: Date) -> (DashboardSection, [DashboardItem]) {
        switch card {
        case .teamAtEvent(let hero):
            return heroRows(hero)
        case .followedEventLive(let live):
            return liveRows(live)
        case .upNext(let upNext):
            return (DashboardSection(id: "upNext", title: "Up next"), upNextRows(upNext, now: now))
        case .recentResults(let recent):
            let items = recent.entries.map { entry -> DashboardItem in
                let name = entry.match.friendlyName(playoffType: entry.event.playoffTypeEnum)
                return .row(
                    DashboardRow(
                        id: "recent-\(entry.team.key)-\(entry.match.key)",
                        title: "\(entry.team.teamNumber) · \(name)",
                        value: result(of: entry.match, for: entry.team.key),
                        action: .match(entry.match, teamKey: entry.team.key)
                    )
                )
            }
            return (DashboardSection(id: "recent", title: "Recent results"), items)
        case .thisWeekEvents(let week):
            let row = DashboardRow(
                id: "thisWeek",
                title: "Events this week",
                value: String(week.events.count),
                action: .tab(.events)
            )
            return (DashboardSection(id: "thisWeek", title: nil), [.row(row)])
        case .season(let phase):
            let (viewModel, tab) = seasonViewModel(for: phase, now: now)
            return (
                DashboardSection(id: "season", title: nil),
                [.summary(viewModel, action: tab.map { DashboardAction.tab($0) })]
            )
        case .getStarted(let signedIn):
            let section = DashboardSection(id: "getStarted", title: "Get started")
            let tiles = [
                DashboardTile(
                    title: signedIn
                        ? "Favorite the teams you follow" : "Sign in to follow your teams",
                    actionTitle: "Open myTBA",
                    style: .blue,
                    tab: .myTBA
                ),
                DashboardTile(
                    title: "Find a team or event",
                    actionTitle: "Search",
                    style: .yellow,
                    tab: .search
                ),
            ]
            return (section, [.tiles(id: section.id, tiles)])
        }
    }

    // MARK: - Cards

    private static func heroRows(_ hero: TeamAtEventCard) -> (DashboardSection, [DashboardItem]) {
        let id = "hero-\(hero.team.key)-\(hero.event.key)"
        var rows: [DashboardRow] = []

        if let ranking = hero.status?.qual?.ranking, let rank = ranking.rank {
            let total = hero.status?.qual?.numTeams.map { " of \($0)" } ?? ""
            rows.append(
                DashboardRow(
                    id: "\(id)-rank",
                    title: "Rank",
                    value: "\(rank)\(rank.suffix)\(total)"
                )
            )
            if let record = ranking.record {
                rows.append(
                    DashboardRow(
                        id: "\(id)-record",
                        title: "Record",
                        value: "\(record.wins)-\(record.losses)-\(record.ties)"
                    )
                )
            }
        }
        if let alliance = hero.status?.alliance {
            let name = alliance.name ?? "Alliance \(alliance.number)"
            rows.append(
                DashboardRow(
                    id: "\(id)-alliance",
                    title: "Alliance",
                    value: alliance.pick == 0 ? "\(name) captain" : "\(name), pick \(alliance.pick)"
                )
            )
        }
        if let pit = hero.status?.pitLocation, !pit.isEmpty {
            rows.append(DashboardRow(id: "\(id)-pit", title: "Pit", value: pit))
        }
        if let next = hero.nextMatch {
            let value = [
                next.friendlyName(playoffType: hero.event.playoffTypeEnum), next.startTimeString,
            ]
            .compactMap { $0 }
            .joined(separator: " · ")
            rows.append(
                DashboardRow(
                    id: "\(id)-next",
                    title: "Next match",
                    value: value,
                    action: .match(next, teamKey: hero.team.key)
                )
            )
        }
        if let last = hero.lastMatch {
            let value = [
                last.friendlyName(playoffType: hero.event.playoffTypeEnum),
                result(of: last, for: hero.team.key),
            ]
            .compactMap { $0 }
            .joined(separator: " · ")
            rows.append(
                DashboardRow(
                    id: "\(id)-last",
                    title: "Last match",
                    value: value,
                    action: .match(last, teamKey: hero.team.key)
                )
            )
        }

        return (
            DashboardSection(id: id, title: "Competing now"),
            [.teamHeader(hero)] + rows.map { DashboardItem.row($0) }
        )
    }

    private static func liveRows(_ live: EventLiveCard) -> (DashboardSection, [DashboardItem]) {
        let id = "live-\(live.event.key)"
        let event = live.event
        var items: [DashboardItem] = [
            .row(
                DashboardRow(
                    id: id,
                    title: event.safeShortName,
                    subtitle: [event.dateString, event.locationString].compactMap { $0 }
                        .joined(separator: " · "),
                    action: .event(event)
                )
            )
        ]
        items += live.rankings.map { ranking -> DashboardItem in
            let record = ranking.record.map { "\($0.wins)-\($0.losses)-\($0.ties)" }
            return .row(
                DashboardRow(
                    id: "\(id)-\(ranking.teamKey)",
                    title: "\(ranking.rank). Team \(ranking.teamKey.trimPrefix)",
                    value: record,
                    isEmphasized: live.followedTeamKeys.contains(ranking.teamKey),
                    action: .teamAtEvent(teamKey: ranking.teamKey, eventKey: event.key)
                )
            )
        }
        if let alliances = live.alliances, !alliances.isEmpty {
            items.append(
                .row(
                    DashboardRow(
                        id: "\(id)-alliances",
                        title: "Alliances",
                        value: "\(alliances.count) selected",
                        action: .event(event)
                    )
                )
            )
        }
        return (DashboardSection(id: id, title: "Happening now"), items)
    }

    // Followed teams headed to the same event share one row.
    private static func upNextRows(_ upNext: UpNextCard, now: Date) -> [DashboardItem] {
        var order: [EventKey] = []
        var grouped: [EventKey: (event: Event, teams: [Team])] = [:]
        for entry in upNext.entries {
            if grouped[entry.event.key] == nil {
                order.append(entry.event.key)
                grouped[entry.event.key] = (entry.event, [])
            }
            if let team = entry.team {
                grouped[entry.event.key]?.teams.append(team)
            }
        }
        return order.compactMap { key in
            guard let (event, teams) = grouped[key] else { return nil }
            let start = event.startDateParsed
            let who: String? = {
                switch teams.count {
                case 0: return nil
                case 1: return "\(teams[0].teamNumber) \(teams[0].displayNickname)"
                default: return teams.map { String($0.teamNumber) }.joined(separator: ", ")
                }
            }()
            let viewModel = DashboardUpNextViewModel(
                month: start?.formatted(monthStyle) ?? "",
                day: start?.formatted(dayStyle) ?? "",
                name: event.safeShortName,
                detail: [who, event.locationString].compactMap { $0 }.joined(separator: " · "),
                relative: start.map { relative(to: $0, from: now) }
            )
            return .upNext(event: event, teamKeys: teams.map(\.key), viewModel)
        }
    }

    // `nil` until the match has been played or when the team wasn't in it.
    private static func result(of match: Match, for teamKey: String) -> String? {
        let red = match.alliances.red
        let blue = match.alliances.blue
        guard red.score >= 0, blue.score >= 0 else { return nil }
        let onRed = red.teamKeys.contains(teamKey)
        guard onRed || blue.teamKeys.contains(teamKey) else { return nil }
        let (ours, theirs) = onRed ? (red.score, blue.score) : (blue.score, red.score)
        let outcome: String
        switch match.winningAlliance {
        case .red: outcome = onRed ? "Won" : "Lost"
        case .blue: outcome = onRed ? "Lost" : "Won"
        default: outcome = "Tied"
        }
        return "\(outcome) \(ours)–\(theirs)"
    }

    private static func seasonViewModel(for phase: DashboardPhase, now: Date) -> (
        DashboardSeasonViewModel, RootType?
    ) {
        switch phase {
        case .offseason(let season):
            return (
                DashboardSeasonViewModel(
                    headline: String(season),
                    title: "season is a wrap",
                    subtitle: "Kickoff for \(season + 1) is coming.",
                    progress: nil,
                    isTappable: false
                ), nil
            )
        case .preKickoff(let season, let kickoff):
            return (
                DashboardSeasonViewModel(
                    headline: countdown(to: kickoff, from: now),
                    title: "until \(season) Kickoff",
                    subtitle: kickoff.formatted(kickoffStyle),
                    progress: nil,
                    isTappable: false
                ), nil
            )
        case .kickoff(let season, let kickoff):
            return (
                DashboardSeasonViewModel(
                    headline: "Kickoff",
                    title: "for \(season) is here",
                    subtitle: kickoff.formatted(kickoffStyle),
                    progress: nil,
                    isTappable: false
                ), nil
            )
        case .buildSeason(let season, let firstEventStart):
            guard let firstEventStart else {
                return (
                    DashboardSeasonViewModel(
                        headline: "Build season",
                        title: "is on, and \(season) events aren't scheduled yet",
                        subtitle: nil,
                        progress: nil,
                        isTappable: true
                    ), .events
                )
            }
            return (
                DashboardSeasonViewModel(
                    headline: countdown(to: firstEventStart, from: now),
                    title: "until \(season) Week 1",
                    subtitle: "Starts \(firstEventStart.formatted(eventDayStyle))",
                    progress: nil,
                    isTappable: true
                ), .events
            )
        case .competition(let season, let week, let weekLabel, let totalWeeks):
            return (
                DashboardSeasonViewModel(
                    headline: weekLabel,
                    title: "of the \(season) season",
                    subtitle: nil,
                    progress: totalWeeks > 0 ? Double(week + 1) / Double(totalWeeks) : nil,
                    isTappable: true
                ), .events
            )
        case .championship(let season):
            return (
                DashboardSeasonViewModel(
                    headline: "Championship",
                    title: "is underway for \(season)",
                    subtitle: nil,
                    progress: nil,
                    isTappable: true
                ), .events
            )
        }
    }

    // MARK: - Dates

    private static func countdown(to date: Date, from now: Date) -> String {
        let days = max(daysUntil(date, from: now), 1)
        return days == 1 ? "1 day" : "\(days) days"
    }

    private static func relative(to date: Date, from now: Date) -> String {
        switch daysUntil(date, from: now) {
        case ..<1: return "Today"
        case 1: return "Tomorrow"
        case let days: return "In \(days) days"
        }
    }

    // Kickoff is an instant and event dates are UTC calendar days, so compare calendar days:
    // the user's today against the date's own day.
    private static func daysUntil(_ date: Date, from now: Date) -> Int {
        let calendar = Calendar.utc
        let today = calendar.date(
            from: Calendar.current.dateComponents([.year, .month, .day], from: now)
        )!
        let target = calendar.date(
            from: calendar.dateComponents([.year, .month, .day], from: date)
        )!
        return calendar.dateComponents([.day], from: today, to: target).day ?? 0
    }

    private static let monthStyle = Date.FormatStyle(timeZone: .gmt).month(.abbreviated)
    private static let dayStyle = Date.FormatStyle(timeZone: .gmt).day()
    private static let eventDayStyle = Date.FormatStyle(timeZone: .gmt).month(.abbreviated).day()
    private static let kickoffStyle = Date.FormatStyle().weekday(.wide).month(.abbreviated).day()
        .hour().minute()

}
