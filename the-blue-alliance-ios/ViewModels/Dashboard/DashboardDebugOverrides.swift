#if DEBUG
    import Foundation
    import MyTBAKit
    import TBAAuth

    /// In-memory knobs for trying the Dashboard at another date or with other follows.
    /// Lives as long as the Dashboard does; nothing is persisted.
    @MainActor
    final class DashboardDebugOverrides {

        struct Scenario: Equatable {
            let title: String
            let now: Date?
        }

        static let scenarios: [Scenario] = [
            Scenario(title: "Right now", now: nil),
            Scenario(title: "Week 3, Friday (Mar 20, 2026)", now: date("2026-03-20T19:00:00Z")),
            Scenario(title: "Week 4, Saturday (Mar 28, 2026)", now: date("2026-03-28T20:00:00Z")),
            Scenario(title: "Championship (Apr 30, 2026)", now: date("2026-04-30T18:00:00Z")),
            Scenario(title: "Offseason event (Sep 19, 2026)", now: date("2026-09-19T20:00:00Z")),
            Scenario(title: "Countdown (Dec 1, 2026)", now: date("2026-12-01T17:00:00Z")),
            Scenario(title: "Kickoff (Jan 9, 2027)", now: date("2027-01-09T18:00:00Z")),
            Scenario(title: "Build season (Feb 1, 2027)", now: date("2027-02-01T17:00:00Z")),
        ]

        var now: Date?
        /// `nil` means use the real favorites.
        var teamKeys: [String]?
        var eventKeys: [String]?
        var signedIn: Bool?

        init() {}

        /// Launch arguments seed the overrides, so a scheme or `simctl launch` can open Home in a
        /// scenario: `-dashboardNow 2026-03-28T20:00:00Z -dashboardTeams 254,1678
        /// -dashboardEvents 2026casj -dashboardSignedIn 1`.
        init(arguments: [String]) {
            func value(for flag: String) -> String? {
                guard let index = arguments.firstIndex(of: flag),
                    arguments.indices.contains(index + 1)
                else { return nil }
                return arguments[index + 1]
            }
            now = value(for: "-dashboardNow").flatMap { try? Date($0, strategy: .iso8601) }
            teamKeys = value(for: "-dashboardTeams").flatMap(Self.teamKeys(from:))
            eventKeys = value(for: "-dashboardEvents").flatMap(Self.eventKeys(from:))
            signedIn = value(for: "-dashboardSignedIn").map { $0 == "1" || $0 == "true" }
        }

        var isActive: Bool {
            now != nil || teamKeys != nil || eventKeys != nil || signedIn != nil
        }

        func effectiveNow() -> Date {
            now ?? Date()
        }

        func effectiveSignedIn(authService: any AuthServiceProtocol) -> Bool {
            signedIn ?? authService.isSignedIn
        }

        func effectiveFollows(favorites: FavoritesStore) -> DashboardFeedBuilder.Follows {
            let real = DashboardFeedBuilder.Follows(favorites: favorites.favorites)
            return .init(
                teamKeys: teamKeys ?? real.teamKeys,
                eventKeys: eventKeys ?? real.eventKeys
            )
        }

        func reset() {
            now = nil
            teamKeys = nil
            eventKeys = nil
            signedIn = nil
        }

        /// "254, 1678" or "254 1678" → `["frc254", "frc1678"]`; empty input → `nil` (use favorites).
        static func teamKeys(from text: String) -> [String]? {
            let keys = tokens(from: text).map { $0.hasPrefix("frc") ? $0 : "frc\($0)" }
            return keys.isEmpty ? nil : keys
        }

        static func eventKeys(from text: String) -> [String]? {
            let keys = tokens(from: text)
            return keys.isEmpty ? nil : keys
        }

        private static func tokens(from text: String) -> [String] {
            text.lowercased()
                .split(whereSeparator: { $0 == "," || $0.isWhitespace })
                .map(String.init)
        }

        private static func date(_ iso: String) -> Date {
            try! Date(iso, strategy: .iso8601)
        }

    }
#endif
