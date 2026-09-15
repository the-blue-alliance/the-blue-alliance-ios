import Foundation
import TBAAPI

/// One card on the Dashboard, in the order they're shown.
nonisolated enum DashboardCard: Hashable {
    case teamAtEvent(TeamAtEventCard)
    case followedEventLive(EventLiveCard)
    case upNext(UpNextCard)
    case recentResults(RecentResultsCard)
    case thisWeekEvents(ThisWeekEventsCard)
    case season(DashboardPhase)
    case getStarted(signedIn: Bool)
}

nonisolated struct TeamAtEventCard: Hashable {
    let team: Team
    let event: Event
    let status: TeamEventStatus?
    let nextMatch: Match?
    let lastMatch: Match?
    /// The team's avatar for the season, base64 PNG as the API sends it.
    let avatarBase64: String?
}

/// A followed event in progress: the top of the rankings plus any followed teams' rows.
nonisolated struct EventLiveCard: Hashable {
    let event: Event
    let rankings: [EventRanking.RankingsPayloadPayload]
    let followedTeamKeys: Set<String>
    let alliances: [EliminationAlliance]?
}

nonisolated struct UpNextCard: Hashable {
    struct Entry: Hashable {
        /// `nil` when the entry is a followed event rather than a followed team's event.
        let team: Team?
        let event: Event
    }
    let entries: [Entry]
}

nonisolated struct RecentResultsCard: Hashable {
    struct Entry: Hashable {
        let team: Team
        let event: Event
        let match: Match
    }
    let entries: [Entry]
}

nonisolated struct ThisWeekEventsCard: Hashable {
    let events: [Event]
}
