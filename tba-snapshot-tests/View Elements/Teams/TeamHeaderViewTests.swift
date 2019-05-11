import Foundation
import TBAKit
import XCTest
@testable import The_Blue_Alliance

class TeamHeaderViewTests: TBASnapshotTestCase {

    var team: Team!

    override func setUp() {
        super.setUp()

        team = coreDataTestFixture.insertTeam()
        let teamMedia = coreDataTestFixture.insertAvatar()
        team.addToMedia(teamMedia)
    }

    func test_no_avatar() {
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: nil))
        verify(teamHeaderView)
    }

    func test_no_avatar_long_name() {
        team.nickname = "The Respectable Awesome Worthy Respectable Robots"
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: nil))
        verify(teamHeaderView)
    }

    func test_no_year_no_avatar_long_name_tall() {
        team.nickname = "The Respectable Awesome Worthy Respectable Robots"
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: nil))
        verify(teamHeaderView, tall: true)
    }

    func test_year_no_avatar() {
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: 2019))
        verify(teamHeaderView)
    }

    func test_avatar() {
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: 2018))
        verify(teamHeaderView)
    }

    func test_avatar_long_name() {
        team.nickname = "The Respectable Awesome Worthy Respectable Robots"
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: 2018))
        verify(teamHeaderView)
    }

    func test_no_avatar_long_number_long_name() {
        team.teamNumber = NSNumber(value: 73332)
        team.nickname = "The Respectable Awesome Worthy Respectable Robots"
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: 2019))
        verify(teamHeaderView)
    }

    func test_avatar_long_number_long_name() {
        team.teamNumber = NSNumber(value: 73332)
        team.nickname = "The Respectable Awesome Worthy Respectable Robots"
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: 2018))
        verify(teamHeaderView)
    }

    func test_year_avatar_red() {
        let teamHeaderView = TeamHeaderView(TeamHeaderViewModel(team: team, year: 2018))
        teamHeaderView.changeAvatarBorder()
        verify(teamHeaderView)
    }

    private func verify(_ view: TeamHeaderView, tall: Bool = false) {
        // Min height for this should be 87px - 55+8+8
        view.frame.size = .init(width: UIScreen.main.bounds.width, height: tall ? 200 : 87)
        verifyView(view)
    }

}
