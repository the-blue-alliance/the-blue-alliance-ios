import XCTest
import Foundation
import CoreData
import FBSnapshotTestCase
@testable import The_Blue_Alliance

class CoreDataTestCase: FBSnapshotTestCase {

    var persistentContainer: NSPersistentContainer!

    static let managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel.mergedModel(from: [Bundle.main])!
    } ()

    override func setUp() {
        super.setUp()

        agnosticOptions = .OS
        // Uncomment to record all new snapshots
        // recordMode = true

        persistentContainer = NSPersistentContainer(name: "TBA", managedObjectModel: CoreDataTestCase.managedObjectModel)

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        description.configuration = "Default"
        persistentContainer.persistentStoreDescriptions = [description]

        let persistentContainerSetupExpectation = XCTestExpectation()
        persistentContainer.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            XCTAssertNotNil(persistentStoreDescription)
            XCTAssertNil(error)

            self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

            persistentContainerSetupExpectation.fulfill()
        })
        wait(for: [persistentContainerSetupExpectation], timeout: 10.0)
    }

    func insertEvent(year: Int = 2015) -> Event {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let model = TBAEvent(key: "\(year)qcmo",
                             name: "FRC Festival de Robotique - Montreal Regional",
                             eventCode: "qcmo",
                             eventType: 0,
                             district: nil,
                             city: nil,
                             stateProv: nil,
                             country: nil,
                             startDate: dateFormatter.date(from: "\(year)-03-18")!,
                             endDate: dateFormatter.date(from: "\(year)-03-21")!,
                             year: year,
                             shortName: "Festival de Robotique - Montreal",
                             eventTypeString: "Reginal",
                             week: 3,
                             address: nil,
                             postalCode: nil,
                             gmapsPlaceID: nil,
                             gmapsURL: nil,
                             lat: nil,
                             lng: nil,
                             locationName: nil,
                             timezone: nil,
                             website: nil,
                             firstEventID: nil,
                             firstEventCode: nil,
                             webcasts: nil,
                             divisionKeys: [],
                             parentEventKey: nil,
                             playoffType: nil,
                             playoffTypeString: nil)

        return Event.insert(model, in: persistentContainer.viewContext)
    }

    func insertDistrictEvent(eventKey: String = "2018miket") -> Event {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let district = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        let model = TBAEvent(key: eventKey,
                             name: "FIM District Kettering University Event #1",
                             eventCode: "miket",
                             eventType: 1,
                             district: district,
                             city: "Flint",
                             stateProv: "MI",
                             country: "USA",
                             startDate: dateFormatter.date(from: "2018-03-01")!,
                             endDate: dateFormatter.date(from: "2018-03-03")!,
                             year: 2018,
                             shortName: "Kettering University #1",
                             eventTypeString: "District",
                             week: 0,
                             address: "1700 University Ave, Flint, MI 48504, USA",
                             postalCode: "48504",
                             gmapsPlaceID: "ChIJLx7Nx2SCI4gRzW8R94I3pEw",
                             gmapsURL: "https://maps.google.com/?cid=5522600078693461965",
                             lat: 43.0115468,
                             lng: -83.7138531,
                             locationName: "Kettering University",
                             timezone: "America/New_York",
                             website: "http://www.firstinmichigan.org",
                             firstEventID: "27941",
                             firstEventCode: "MIKET",
                             webcasts: nil,
                             divisionKeys: [],
                             parentEventKey: nil,
                             playoffType: nil,
                             playoffTypeString: nil)

        return Event.insert(model, in: persistentContainer.viewContext)
    }

    func insertTeam() -> Team {
        let team = TBATeam(key: "frc7332",
                           teamNumber: 7332,
                           nickname: "The Rawrbotz",
                           name: "General Motors/Premier Tooling Systems/Microsoft/The Chrysler Foundation/Davison Tool & Engineering, L.L.C./The Robot Space/Michigan Department of Education/Kettering University/Taylor Steel/DXC Technology/Complete Scrap/ZF North America & Grand Blanc Community High School",
                           city: nil,
                           stateProv: nil,
                           country: nil,
                           address: nil,
                           postalCode: nil,
                           gmapsPlaceID: nil,
                           gmapsURL: nil,
                           lat: nil,
                           lng: nil,
                           locationName: nil,
                           website: nil,
                           rookieYear: 2010,
                           motto: nil,
                           homeChampionship: nil)
        return Team.insert(team, in: persistentContainer.viewContext)
    }

    func insertDistrict() -> District {
        let district = TBADistrict(abbreviation: "fim", name: "FIRST In Michigan", key: "2018fim", year: 2018)
        return District.insert(district, in: persistentContainer.viewContext)
    }

    func verifyView(_ view: UIView, identifier: String = "") {
        FBSnapshotVerifyView(view,
                             identifier: identifier,
                             suffixes: NSOrderedSet(array: [""]))
    }

    func verifyLayer(_ layer: CALayer, identifier: String = "") {
        FBSnapshotVerifyLayer(layer,
                              identifier: identifier,
                              suffixes: NSOrderedSet(array: [""]))
    }

}
