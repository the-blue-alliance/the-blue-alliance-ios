import Intents
import Search
import TBADataTesting
import TBAKit
import XCTest
@testable import TBAData

class SearchableTestCase: TBADataTestCase {

    func test_userActivity() {
        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(model, in: persistentContainer.viewContext)
        _ = Favorite.insert(modelKey: model.key, modelType: .team, in: persistentContainer.viewContext)

        let activity = team.userActivity
        XCTAssertEqual(activity.title!, team.searchAttributes.displayName!)
        XCTAssertNotNil(activity.contentAttributeSet)
        // Make sure we have de-dupe information
        XCTAssertEqual(activity.contentAttributeSet!.contentURL, team.webURL)
        XCTAssertEqual(activity.contentAttributeSet!.relatedUniqueIdentifier, team.uniqueIdentifier)
        XCTAssertEqual(activity.contentAttributeSet!.userCurated?.boolValue, team.userCurated)

        XCTAssertEqual(activity.userInfo as! [String: AnyHashable], [TBAActivityURL: team.webURL])
        XCTAssertEqual(activity.webpageURL, team.webURL)
        XCTAssertEqual(activity.requiredUserInfoKeys, [TBAActivityURL])

        XCTAssert(activity.isEligibleForPublicIndexing)
        XCTAssert(activity.isEligibleForSearch)
        XCTAssert(activity.isEligibleForHandoff)
        XCTAssert(activity.isEligibleForPrediction)
        XCTAssertEqual(activity.persistentIdentifier, team.uniqueIdentifier)
    }

    func test_userActivity_userCurated() {
        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(model, in: persistentContainer.viewContext)

        let activity = team.userActivity
        XCTAssertNil(activity.contentAttributeSet!.userCurated)
    }

    func test_relevantShortcut_event_none() {
        let event = insertEvent()
        event.startDateRaw = nil
        event.endDateRaw = nil
        event.latRaw = nil
        event.lngRaw = nil

        let shortcut = event.relevantShortcut
        XCTAssertNotNil(shortcut.shortcut.userActivity)
        XCTAssertEqual(shortcut.shortcut.userActivity!.persistentIdentifier, event.userActivity.persistentIdentifier)
        XCTAssertEqual(shortcut.relevanceProviders.count, 0)
    }

    func test_relevantShortcut_event_date() {
        let event = insertEvent()

        let shortcut = event.relevantShortcut
        XCTAssertNotNil(shortcut.shortcut.userActivity)
        XCTAssertEqual(shortcut.shortcut.userActivity!.persistentIdentifier, event.userActivity.persistentIdentifier)
        XCTAssertEqual(shortcut.relevanceProviders.count, 1)

        let date = shortcut.relevanceProviders.first { $0 is INDateRelevanceProvider } as! INDateRelevanceProvider
        XCTAssertEqual(date.startDate, event.startDate!)
        XCTAssertEqual(date.endDate, event.endDate!)
    }

    func test_relevantShortcut_event_location() {
        let event = insertEvent()
        event.startDateRaw = nil
        event.endDateRaw = nil
        event.latRaw = NSNumber(value: 45.5328391)
        event.lngRaw = NSNumber(value: -73.6271923)
        event.locationNameRaw = "Uniprix Stadium"

        var shortcut = event.relevantShortcut
        XCTAssertNotNil(shortcut.shortcut.userActivity)
        XCTAssertEqual(shortcut.shortcut.userActivity!.persistentIdentifier, event.userActivity.persistentIdentifier)
        XCTAssertEqual(shortcut.relevanceProviders.count, 1)

        var location = shortcut.relevanceProviders.first { $0 is INLocationRelevanceProvider } as! INLocationRelevanceProvider
        XCTAssertEqual(location.region.identifier, event.locationName!)

        event.locationNameRaw = nil
        event.cityRaw = "Atlanta"
        event.stateProvRaw = "GA"
        event.countryRaw = "USA"

        shortcut = event.relevantShortcut
        location = shortcut.relevanceProviders.first { $0 is INLocationRelevanceProvider } as! INLocationRelevanceProvider
        XCTAssertEqual(location.region.identifier, event.locationString!)

        event.cityRaw = nil
        event.stateProvRaw = nil
        event.countryRaw = nil

        shortcut = event.relevantShortcut
        location = shortcut.relevanceProviders.first { $0 is INLocationRelevanceProvider } as! INLocationRelevanceProvider
        XCTAssertEqual(location.region.identifier, event.safeNameYear)
    }

    func test_relevantShortcut_team() {
        let model = TBATeam(key: "frc7332", teamNumber: 7332, name: "The Rawrbotz", rookieYear: 2010)
        let team = Team.insert(model, in: persistentContainer.viewContext)

        let shortcut = team.relevantShortcut
        XCTAssertNotNil(shortcut.shortcut.userActivity)
        XCTAssertEqual(shortcut.shortcut.userActivity!.persistentIdentifier, team.userActivity.persistentIdentifier)
        XCTAssert(shortcut.relevanceProviders.isEmpty)
    }

}
