import Foundation
import TBAAPI

class DistrictEventsViewController: EventsViewController {

    override class var firstEventSortKeyPathComparators: [KeyPathComparator<Event>] {
        [KeyPathComparator(\.week)]
    }

    private let district: District

    init(district: District, dependencyProvider: DependencyProvider) {
        self.district = district

        super.init(dependencyProvider: dependencyProvider)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override func performRefresh() async throws {
        guard let api = dependencyProvider?.api else { return }
        let response = try await api.getDistrictEvents(.init(path: .init(districtKey: district.key)))
        events = try response.ok.body.json
    }

    // MARK: - Stateful

    override var noDataText: String? {
        "No events for district"
    }

}
