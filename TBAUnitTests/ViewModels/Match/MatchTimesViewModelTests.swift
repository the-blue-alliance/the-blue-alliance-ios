import Foundation
import TBAAPI
import Testing

@testable import The_Blue_Alliance

struct MatchTimesViewModelTests {

    // 2026-03-07 14:30:00 UTC — 9:30 AM in Detroit, 6:30 AM in Los Angeles.
    private static let scheduled: Int64 = 1_772_893_800
    private static let detroit = TimeZone(identifier: "America/Detroit")!
    private static let losAngeles = TimeZone(identifier: "America/Los_Angeles")!
    private static let newYork = TimeZone(identifier: "America/New_York")!
    private static let locale = Locale(identifier: "en_US")

    // Foundation separates the hour from AM with a narrow no-break space.
    private static func am(_ time: String) -> String { "\(time)\u{202F}AM" }

    private static func makeViewModel(
        time: Int64? = nil,
        actualTime: Int64? = nil,
        predictedTime: Int64? = nil,
        eventTimeZone: TimeZone? = detroit,
        showsDeviceTimeZone: Bool = false,
        deviceTimeZone: TimeZone = losAngeles
    ) -> MatchTimesViewModel {
        MatchTimesViewModel(
            match: makeMatch(time: time, actualTime: actualTime, predictedTime: predictedTime),
            eventTimeZone: eventTimeZone,
            showsDeviceTimeZone: showsDeviceTimeZone,
            deviceTimeZone: deviceTimeZone,
            locale: locale
        )
    }

    @Test func noTimesMeansNoRows() {
        let viewModel = Self.makeViewModel()
        #expect(viewModel.isEmpty)
        #expect(viewModel.rows.isEmpty)
    }

    @Test func rowsFollowTheEventClockWhenNotShowingDeviceTime() {
        let viewModel = Self.makeViewModel(
            time: Self.scheduled,
            actualTime: Self.scheduled + 120,
            predictedTime: Self.scheduled + 60
        )
        #expect(viewModel.canToggleTimeZone)
        #expect(
            viewModel.rows == [
                .init(title: "Date", value: "Sat, Mar 7", detail: nil),
                .init(title: "Actual", value: Self.am("9:32"), detail: "2m late"),
                .init(title: "Scheduled", value: Self.am("9:30"), detail: nil),
                .init(title: "Predicted", value: Self.am("9:31"), detail: nil),
            ]
        )
    }

    @Test func showingDeviceTimeMovesRowsToTheDeviceClock() {
        let viewModel = Self.makeViewModel(time: Self.scheduled, showsDeviceTimeZone: true)
        #expect(viewModel.rows.map(\.value) == ["Sat, Mar 7", Self.am("6:30")])
    }

    @Test func onlyTheRowsWithTimesAppear() {
        let viewModel = Self.makeViewModel(predictedTime: Self.scheduled)
        #expect(viewModel.rows.map(\.title) == ["Date", "Predicted"])
        #expect(viewModel.rows.last?.detail == nil)
    }

    @Test func actualWithoutScheduledHasNoOffScheduleDetail() {
        let viewModel = Self.makeViewModel(actualTime: Self.scheduled)
        #expect(viewModel.rows.map(\.title) == ["Date", "Actual"])
        #expect(viewModel.rows.last?.detail == nil)
    }

    @Test func noEventTimeZoneStaysOnTheDeviceClockWithoutAToggle() {
        let viewModel = Self.makeViewModel(time: Self.scheduled, eventTimeZone: nil)
        #expect(!viewModel.canToggleTimeZone)
        #expect(viewModel.rows.map(\.value) == ["Sat, Mar 7", Self.am("6:30")])
    }

    @Test func sameClockInADifferentZoneOffersNoToggle() {
        let viewModel = Self.makeViewModel(time: Self.scheduled, deviceTimeZone: Self.newYork)
        #expect(!viewModel.canToggleTimeZone)
        #expect(viewModel.rows.map(\.value) == ["Sat, Mar 7", Self.am("9:30")])
    }

    @Test func offScheduleWording() {
        let scheduled = Self.scheduled
        #expect(
            MatchTimesViewModel.offSchedule(actual: scheduled, scheduled: scheduled) == "on time"
        )
        #expect(
            MatchTimesViewModel.offSchedule(actual: scheduled + 20, scheduled: scheduled)
                == "on time"
        )
        #expect(
            MatchTimesViewModel.offSchedule(actual: scheduled + 720, scheduled: scheduled)
                == "12m late"
        )
        #expect(
            MatchTimesViewModel.offSchedule(actual: scheduled - 720, scheduled: scheduled)
                == "12m early"
        )
        #expect(
            MatchTimesViewModel.offSchedule(actual: scheduled + 3600, scheduled: scheduled)
                == "1h late"
        )
        #expect(
            MatchTimesViewModel.offSchedule(actual: scheduled - 3900, scheduled: scheduled)
                == "1h 5m early"
        )
    }

    // MARK: - Test helpers

    private static func makeMatch(time: Int64?, actualTime: Int64?, predictedTime: Int64?) -> Match
    {
        Match(
            key: "2026miket_qm1",
            compLevel: .qm,
            setNumber: 1,
            matchNumber: 1,
            alliances: Match.AlliancesPayload(
                red: MatchAlliance(score: -1, teamKeys: [], surrogateTeamKeys: [], dqTeamKeys: []),
                blue: MatchAlliance(score: -1, teamKeys: [], surrogateTeamKeys: [], dqTeamKeys: [])
            ),
            winningAlliance: ._empty_,
            eventKey: "2026miket",
            time: time,
            actualTime: actualTime,
            predictedTime: predictedTime,
            videos: []
        )
    }

}
