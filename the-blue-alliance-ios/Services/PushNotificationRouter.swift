import Foundation
import MyTBAKit
import UIKit

@MainActor
protocol PushNotificationRouting: AnyObject {
    var rootViewController: UIViewController? { get set }
    func handleTap(_ payload: PushNotificationPayload)
    func performSilentRefresh(_ kind: PushNotificationPayload.SilentKind) async
}

@MainActor
final class PushNotificationRouter: PushNotificationRouting {

    private let dependencies: Dependencies
    weak var rootViewController: UIViewController?

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Tap routing

    func handleTap(_ payload: PushNotificationPayload) {
        switch payload {
        case let .match(_, matchKey, _, teamKey):
            presentMatch(matchKey: matchKey, teamKey: teamKey)
        case .silentRefresh(let kind):
            // Silent pushes shouldn't normally reach the tap path, but if one
            // ever does (e.g. server misroutes one as visible), still refresh.
            Task { await performSilentRefresh(kind) }
        case .unhandled(let typeKey):
            dependencies.reporter.log("Unhandled push notification tap: \(typeKey)")
        }
    }

    private func presentMatch(matchKey: String, teamKey: String?) {
        guard let presenter = topPresenter() else {
            dependencies.reporter.log("Push routing: no presenter for match \(matchKey)")
            return
        }
        let matchVC = MatchViewController(
            matchKey: matchKey,
            teamKey: teamKey,
            dependencies: dependencies
        )
        let nav = UINavigationController(rootViewController: matchVC)
        matchVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak nav] _ in nav?.dismiss(animated: true) }
        )
        nav.modalPresentationStyle = .formSheet
        presenter.present(nav, animated: true)
    }

    // Walks the presented-VC chain so we present on top of any modal that's
    // already up (e.g. the user tapped a notification while a sheet was open).
    private func topPresenter() -> UIViewController? {
        var current = rootViewController
        while let presented = current?.presentedViewController {
            current = presented
        }
        return current
    }

    // MARK: - Silent refresh

    func performSilentRefresh(_ kind: PushNotificationPayload.SilentKind) async {
        guard dependencies.myTBA.isAuthenticated else { return }
        do {
            switch kind {
            case .favorites:
                let favorites = try await dependencies.myTBA.fetchFavorites()
                dependencies.myTBAStores.favorites.replaceAll(with: favorites)
            case .subscriptions:
                let subscriptions = try await dependencies.myTBA.fetchSubscriptions()
                dependencies.myTBAStores.subscriptions.replaceAll(with: subscriptions)
            }
        } catch {
            dependencies.reporter.record(error)
        }
    }
}
