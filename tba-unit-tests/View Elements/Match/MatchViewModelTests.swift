import TBADataTesting
import XCTest
@testable import TBAData
@testable import The_Blue_Alliance

class MatchViewModelTestCase: TBADataTestCase {

    func test_no_breakdown() {
        let match = insertMatch(eventKey: "2018inwla")

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 0)
        XCTAssertEqual(subject.blueRPCount, 0)
    }

    func test_bad_bereakdown_keys() {
        let match = insertMatch(eventKey: "2018inwla")
        match.breakdownRaw = [
            "red": [
                "notThere1": false,
                "notThere2": false
            ],
            "blue": [
                "notThere1": false,
                "notThere2": false
            ]
        ]

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 0)
        XCTAssertEqual(subject.blueRPCount, 0)
    }

    func test_no_rp() {
        let match = insertMatch(eventKey: "2018inwla")
        match.breakdownRaw = [
            "red": [
                "autoQuestRankingPoint": false,
                "faceTheBossRankingPoint": false
            ],
            "blue": [
                "autoQuestRankingPoint": false,
                "faceTheBossRankingPoint": false
            ]
        ]

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 0)
        XCTAssertEqual(subject.blueRPCount, 0)
    }

    func test_first_rp() {
        let match = insertMatch(eventKey: "2018inwla")
        match.breakdownRaw = [
            "red": [
                "autoQuestRankingPoint": true,
                "faceTheBossRankingPoint": false
            ],
            "blue": [
                "autoQuestRankingPoint": true,
                "faceTheBossRankingPoint": false
            ]
        ]

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 1)
        XCTAssertEqual(subject.blueRPCount, 1)
    }

    func test_second_rp() {
        let match = insertMatch(eventKey: "2018inwla")
        match.breakdownRaw = [
            "red": [
                "autoQuestRankingPoint": false,
                "faceTheBossRankingPoint": true
            ],
            "blue": [
                "autoQuestRankingPoint": false,
                "faceTheBossRankingPoint": true
            ]
        ]

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 1)
        XCTAssertEqual(subject.blueRPCount, 1)
    }

    func test_both_rp() {
        let match = insertMatch(eventKey: "2018inwla")
        match.breakdownRaw = [
            "red": [
                "autoQuestRankingPoint": true,
                "faceTheBossRankingPoint": true
            ],
            "blue": [
                "autoQuestRankingPoint": true,
                "faceTheBossRankingPoint": true
            ]
        ]

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 2)
        XCTAssertEqual(subject.blueRPCount, 2)
    }

    func test_2018_rp() {
        let match = insertMatch(eventKey: "2018inwla")
        match.breakdownRaw = [
            "red": [
                "autoQuestRankingPoint": true,
                "faceTheBossRankingPoint": true
            ],
            "blue": [
                "autoQuestRankingPoint": true,
                "faceTheBossRankingPoint": true
            ]
        ]

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 2)
        XCTAssertEqual(subject.blueRPCount, 2)
    }

    func test_2017_rp() {
        let match = insertMatch(eventKey: "2017inwla")
        match.breakdownRaw = [
            "red": [
                "kPaRankingPointAchieved": true,
                "rotorRankingPointAchieved": true
            ],
            "blue": [
                "kPaRankingPointAchieved": true,
                "rotorRankingPointAchieved": true
            ]
        ]

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 2)
        XCTAssertEqual(subject.blueRPCount, 2)
    }

    func test_2016_rp() {
        let match = insertMatch(eventKey: "2016inwla")
        match.breakdownRaw = [
            "red": [
                "teleopDefensesBreached": true,
                "teleopTowerCaptured": true
            ],
            "blue": [
                "teleopDefensesBreached": true,
                "teleopTowerCaptured": true
            ]
        ]

        let subject = MatchViewModel(match: match)
        XCTAssertEqual(subject.redRPCount, 2)
        XCTAssertEqual(subject.blueRPCount, 2)
    }

}
