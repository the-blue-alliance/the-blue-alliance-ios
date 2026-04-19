#if SCREENSHOT_MODE
import Foundation
import MyTBAKit
import TBAAPI
import TBAUtils
import UIKit

extension Dependencies {

    static func screenshotMocked() -> Dependencies {
        let api = TBAAPI(apiKey: "fake",
                         cachePolicy: .bypass,
                         protocolClasses: [FixtureURLProtocol.self])
        let appSettings = AppSettings()
        let myTBA = MockMyTBA()
        let myTBAStores = MyTBAStores(favorites: FavoritesStore(),
                                      subscriptions: SubscriptionsStore())
        let statusService = MockStatusService()
        let urlOpener = MockURLOpener()

        return Dependencies(api: api,
                            appSettings: appSettings,
                            myTBA: myTBA,
                            myTBAStores: myTBAStores,
                            statusService: statusService,
                            urlOpener: urlOpener)
    }
}

private final class MockStatusService: StatusServiceProtocol {
    var status: AppStatus = .default
    var currentSeason: Int { status.currentSeason }
    var maxSeason: Int { status.maxSeason }

    func registerForStatusChanges(_ subscriber: StatusSubscribable) {}
    func registerForFMSStatusChanges(_ subscriber: FMSStatusSubscribable) {}
    func registerForEventStatusChanges(_ subscriber: EventStatusSubscribable, eventKey: String) {}
    func registerRetryable(initiallyRetry: Bool) {}
    func unregisterRetryable() {}
}

private final class MockURLOpener: URLOpener {
    func canOpenURL(_ url: URL) -> Bool { true }
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: (@MainActor @Sendable (Bool) -> Void)?) {
        Task { @MainActor in completionHandler?(true) }
    }
}
#endif
