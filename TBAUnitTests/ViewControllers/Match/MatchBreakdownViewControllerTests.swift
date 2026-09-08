import Testing

@testable import The_Blue_Alliance

@MainActor
struct MatchBreakdownViewControllerTests {

    @Test(arguments: [2013, 2014])
    func yearsWithoutABreakdownDoNotSupportRefreshing(_ year: Int) {
        let controller = MatchBreakdownViewController(
            matchKey: "\(year)test_qm1",
            year: year,
            dependencies: .mock()
        )
        #expect(!controller.supportsRefreshing)
    }

    @Test(arguments: [2015, 2020, 2021, 2026])
    func yearsWithABreakdownSupportRefreshing(_ year: Int) {
        let controller = MatchBreakdownViewController(
            matchKey: "\(year)test_qm1",
            year: year,
            dependencies: .mock()
        )
        #expect(controller.supportsRefreshing)
    }

}
