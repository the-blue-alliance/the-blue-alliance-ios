import Foundation
import TBAKit
@testable import The_Blue_Alliance

class TeamHeaderViewTests: TBASnapshotTestCase {

    var team: Team!

    override func setUp() {
        super.setUp()

        team = coreDataTestFixture.insertTeam()

        let avatarData = "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALEgAACxIB0t1+/AAAAXxJREFUWEft1sFOwzAQRdGCYMP/fyBrVlQgdlA8VSZ6mVwntuNIXhTpiOZ5Yk+sNOkl/d0Gh+FIMBwJhpteRQqQj9P5lTDc9FeBzq+EYRY1UYLmKoQhooVr0bw7MFzRRb6Tt+nzR6LjfuyszuqNn6vjBTBc8MV1AW8w1vhx5PV7dQDDBZ+04epXGubCcNazOdO1wd7NGb8nfW6qCTC8692cejR4VJcGrbkzGyycG8PZGQ0+JxXzYjgSDGd+r7jf5Jp8Tf8/k1hTotsO2nNLj2kxozU/U6ZiQ3HeDRjObOInOY4LOz2HxrVBm6/bDtqvE71aWtzoOTRut4TWxF89GzBcsAX0M4n10Xui41q/A8MFndDfpS63E1pjdOzUBnvo3qDtQMW3blfc0R0YrlROmtUwD4boaJON52OYZYu8hKzEgYvDMKt1oUeDqvaxc/AxheGm4Rs0pe/SinduDoZFbGdy95aNHdw5h2Gx+G52VNsIw5FgOBIMR4LhIC63f5+pFSb1yhjZAAAAAElFTkSuQmCC"
        let modelMedia = TBAMedia(
            key: "avatar_2018_frc7332",
            type: "avatar",
            foreignKey: nil,
            details: ["base64Image": avatarData],
            preferred: false,
            directURL: "",
            viewURL: ""
        )
        let teamMedia = TeamMedia.insert(modelMedia, year: 2018, in: context)
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
        view.frame.size = .init(width: 320, height: tall ? 200 : 87)
        verifyView(view)
    }

}
