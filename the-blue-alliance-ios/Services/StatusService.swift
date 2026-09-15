import Foundation
import Observation
import TBAAPI
import TBAUtils

struct AppStatus: Equatable {
    let currentSeason: Int
    let maxSeason: Int
    let minAppVersion: Int
    let latestAppVersion: Int
    let isDatafeedDown: Bool
    let downEventKeys: [String]
    /// Kickoff for the upcoming season, as the server computes it. `nil` until `/status` has
    /// loaded or if the server omits it.
    let kickoffDate: Date?

    static var `default`: AppStatus {
        let year = Calendar.current.component(.year, from: Date())
        return AppStatus(
            currentSeason: year,
            maxSeason: year,
            minAppVersion: -1,
            latestAppVersion: -1,
            isDatafeedDown: false,
            downEventKeys: [],
            kickoffDate: nil
        )
    }

    init(
        currentSeason: Int,
        maxSeason: Int,
        minAppVersion: Int,
        latestAppVersion: Int,
        isDatafeedDown: Bool,
        downEventKeys: [String],
        kickoffDate: Date?
    ) {
        self.currentSeason = currentSeason
        self.maxSeason = maxSeason
        self.minAppVersion = minAppVersion
        self.latestAppVersion = latestAppVersion
        self.isDatafeedDown = isDatafeedDown
        self.downEventKeys = downEventKeys
        self.kickoffDate = kickoffDate
    }

    init(apiStatus: APIStatus) {
        self.currentSeason = apiStatus.currentSeason
        self.maxSeason = apiStatus.maxSeason
        self.minAppVersion = apiStatus.ios.minAppVersion
        self.latestAppVersion = apiStatus.ios.latestAppVersion
        self.isDatafeedDown = apiStatus.isDatafeedDown
        self.downEventKeys = apiStatus.downEvents
        self.kickoffDate = apiStatus.kickoffDatetime.flatMap { try? Date($0, strategy: .iso8601) }
    }
}

protocol StatusServiceProtocol: AnyObject {
    var status: AppStatus { get }
    var currentSeason: Int { get }
    var maxSeason: Int { get }

    func start()
}

@Observable
final class StatusService: StatusServiceProtocol {

    private let reporter: any Reporter
    private let api: any TBAAPIProtocol

    private(set) var status: AppStatus = .default

    @ObservationIgnored private var pollTask: Task<Void, Never>?
    @ObservationIgnored private var foregroundObserver: NotificationCenter.ObservationToken?

    var currentSeason: Int { status.currentSeason }
    var maxSeason: Int { status.maxSeason }

    init(reporter: any Reporter, api: any TBAAPIProtocol) {
        self.reporter = reporter
        self.api = api
    }

    func start() {
        startPolling()
        // Coming back checks right away, then every five minutes from there.
        foregroundObserver = NotificationCenter.default.addForegroundObserver { [weak self] in
            self?.startPolling()
        }
    }

    private func startPolling() {
        pollTask?.cancel()
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                await fetchStatus()
                try? await Task.sleep(for: .seconds(5 * 60))
            }
        }
    }

    private func fetchStatus() async {
        do {
            let newStatus = AppStatus(apiStatus: try await api.getStatus())
            // Every assignment notifies observers, and this polls every five minutes.
            if newStatus != status {
                status = newStatus
            }
        } catch {
            reporter.record(error)
        }
    }

}
