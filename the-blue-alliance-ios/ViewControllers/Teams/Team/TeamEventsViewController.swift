import Foundation
import TBAAPI

class TeamEventsViewController: EventsListViewController {

    private let teamKey: String
    var year: Int? {
        didSet {
            if oldValue == year { return }
            refresh()
        }
    }

    init(teamKey: String, year: Int? = nil, dependencies: Dependencies) {
        self.teamKey = teamKey
        self.year = year

        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - EventsListViewController

    override func loadEvents() async throws -> [APIEvent] {
        guard let year else { return [] }
        return try await dependencies.api.teamEventsByYear(key: teamKey, year: year)
    }

    // MARK: - Stateful

    override var noDataText: String? { "No events for team" }
}
