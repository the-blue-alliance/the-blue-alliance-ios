import Foundation
import TBAAPI

class DistrictEventsViewController: SimpleEventsViewController {

    override class var firstEventKeyPathComparator: KeyPathComparator<Event> {
        KeyPathComparator(\.week)
    }

    private let district: District
    private let api: TBAAPI

    init(district: District, api: TBAAPI) {
        self.district = district
        self.api = api

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override func performRefresh() async throws {
        events = try await api.getDistrictEvents(districtKey: district.key)
    }

    // MARK: - Stateful

    override var noDataText: String? {
        "No events for district"
    }

}
