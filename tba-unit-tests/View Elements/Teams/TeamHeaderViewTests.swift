import Foundation
import XCTest
@testable import TBAData
@testable import The_Blue_Alliance

class TeamHeaderViewModelTests: TBATestCase {

    var team: Team!

    override func setUp() {
        super.setUp()

        team = Team.init(entity: Team.entity(), insertInto: persistentContainer.viewContext)
        team.teamNumberRaw = NSNumber(value: 7332)
    }

    func test_no_nickname_no_year_no_avatar() {
        let vm = TeamHeaderViewModel(team: team, year: nil)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertNil(vm.nickname)
        XCTAssertNil(vm.avatar)
        XCTAssertNil(vm.year)
    }

    func test_no_nickname_year_no_avatar() {
        let vm = TeamHeaderViewModel(team: team, year: 2018)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertNil(vm.nickname)
        XCTAssertNil(vm.avatar)
        XCTAssertEqual(vm.year, 2018)
    }

    func test_nickname_no_year_no_avatar() {
        team.nicknameRaw = "The Rawrbotz"

        let vm = TeamHeaderViewModel(team: team, year: nil)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertEqual(vm.nickname, "The Rawrbotz")
        XCTAssertNil(vm.avatar)
        XCTAssertNil(vm.year)
    }

    func test_nickname_year_no_avatar() {
        team.nicknameRaw = "The Rawrbotz"

        let vm = TeamHeaderViewModel(team: team, year: 2018)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertEqual(vm.nickname, "The Rawrbotz")
        XCTAssertNil(vm.avatar)
        XCTAssertEqual(vm.year, 2018)
    }

    func test_no_nickname_no_year_avatar() {
        let avatar = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        avatar.yearRaw = 2018
        avatar.typeStringRaw = MediaType.avatar.rawValue
        team.addToMediaRaw(avatar)

        let vm = TeamHeaderViewModel(team: team, year: nil)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertNil(vm.nickname)
        XCTAssertNil(vm.avatar)
        XCTAssertNil(vm.year)
    }

    func test_no_nickname_different_year_avatar() {
        let avatar = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        avatar.yearRaw = 2018
        avatar.typeStringRaw = MediaType.avatar.rawValue
        team.addToMediaRaw(avatar)

        let vm = TeamHeaderViewModel(team: team, year: 2019)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertNil(vm.nickname)
        XCTAssertNil(vm.avatar)
        XCTAssertEqual(vm.year, 2019)
    }

    func test_no_nickname_year_avatar() {
        insertAvatar()

        let vm = TeamHeaderViewModel(team: team, year: 2018)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertNil(vm.nickname)
        XCTAssertNotNil(vm.avatar)
        XCTAssertEqual(vm.year, 2018)
    }

    func test_nickname_different_year_avatar() {
        team.nicknameRaw = "The Rawrbotz"
        insertAvatar()

        let vm = TeamHeaderViewModel(team: team, year: 2018)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertEqual(vm.nickname, "The Rawrbotz")
        XCTAssertNotNil(vm.avatar)
        XCTAssertEqual(vm.year, 2018)
    }

    func test_nickname_year_avatar() {
        team.nicknameRaw = "The Rawrbotz"
        insertAvatar()

        let vm = TeamHeaderViewModel(team: team, year: 2018)

        XCTAssertEqual(vm.teamNumberNickname, "Team 7332")
        XCTAssertEqual(vm.nickname, "The Rawrbotz")
        XCTAssertNotNil(vm.avatar)
        XCTAssertEqual(vm.year, 2018)
    }

    private func insertAvatar() {
        let avatar = TeamMedia.init(entity: TeamMedia.entity(), insertInto: persistentContainer.viewContext)
        avatar.yearRaw = 2018
        avatar.typeStringRaw = MediaType.avatar.rawValue
        avatar.detailsRaw = ["base64Image": "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALEgAACxIB0t1+/AAAAXxJREFUWEft1sFOwzAQRdGCYMP/fyBrVlQgdlA8VSZ6mVwntuNIXhTpiOZ5Yk+sNOkl/d0Gh+FIMBwJhpteRQqQj9P5lTDc9FeBzq+EYRY1UYLmKoQhooVr0bw7MFzRRb6Tt+nzR6LjfuyszuqNn6vjBTBc8MV1AW8w1vhx5PV7dQDDBZ+04epXGubCcNazOdO1wd7NGb8nfW6qCTC8692cejR4VJcGrbkzGyycG8PZGQ0+JxXzYjgSDGd+r7jf5Jp8Tf8/k1hTotsO2nNLj2kxozU/U6ZiQ3HeDRjObOInOY4LOz2HxrVBm6/bDtqvE71aWtzoOTRut4TWxF89GzBcsAX0M4n10Xui41q/A8MFndDfpS63E1pjdOzUBnvo3qDtQMW3blfc0R0YrlROmtUwD4boaJON52OYZYu8hKzEgYvDMKt1oUeDqvaxc/AxheGm4Rs0pe/SinduDoZFbGdy95aNHdw5h2Gx+G52VNsIw5FgOBIMR4LhIC63f5+pFSb1yhjZAAAAAElFTkSuQmCC"]
        team.addToMediaRaw(avatar)
    }

}
