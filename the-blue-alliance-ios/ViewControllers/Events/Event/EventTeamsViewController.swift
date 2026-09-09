import Foundation
import TBAAPI

class EventTeamsViewController: TeamsListViewController<Team> {

    let eventKey: EventKey

    private var pitLocations: [String: String] = [:]

    // MARK: Init

    init(eventKey: EventKey, dependencies: Dependencies) {
        self.eventKey = eventKey

        super.init(showSearch: false, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadTeams() async throws -> [Team] {
        // Unstructured Task handles instead of `async let`: Swift 6.1's
        // async-let stack allocator trips swift_task_dealloc's LIFO check
        // here even with reverse-order awaits (#995 didn't fully fix it).
        // Task handles heap-allocate and sidestep the allocator entirely.
        // See https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/996
        let teamsHandle = Task { try await dependencies.api.eventTeams(key: eventKey) }
        let statusesHandle = Task { try? await dependencies.api.eventTeamsStatuses(key: eventKey) }

        let loadedTeams = try await teamsHandle.value
        let loadedStatuses = await statusesHandle.value ?? [:]

        pitLocations = loadedStatuses.compactMapValues { $0.pitLocation }
        return loadedTeams
    }

    override func numberSubtitle(for team: Team) -> String? {
        pitLocations[team.key].map { "Pit \($0)" }
    }

    override var noDataText: String? { "No teams for event" }
}
