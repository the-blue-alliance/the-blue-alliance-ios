import Foundation
import TBAAPI

class DistrictEventsViewController: EventsListViewController {

    let districtKey: String
    let year: Int

    init(districtKey: String, year: Int, dependencies: Dependencies) {
        self.districtKey = districtKey
        self.year = year
        super.init(dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadEvents() async throws -> [APIEvent] {
        try await dependencies.api.districtEvents(key: districtKey)
    }

    override var noDataText: String? { "No events for district" }
}
