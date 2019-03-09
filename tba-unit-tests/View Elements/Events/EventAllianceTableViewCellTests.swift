import XCTest
@testable import TBA

class EventAllianceTableViewCellTestCase: CoreDataTestCase {

    override func setUp() {
        super.setUp()
    }

    func test_init() {
        let nib = EventAllianceTableViewCell.nib
        let cell = nib?.instantiate(withOwner: self, options: nil).first as! EventAllianceTableViewCell
        XCTAssertEqual(cell.selectionStyle, .none)
    }

    func test_configureCell() {
        let nib = EventAllianceTableViewCell.nib
        let cell = nib?.instantiate(withOwner: self, options: nil).first as! EventAllianceTableViewCell

        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.addToPicks(NSOrderedSet(array: [
            TeamKey.insert(withKey: "frc1", in: persistentContainer.viewContext),
            TeamKey.insert(withKey: "frc3", in: persistentContainer.viewContext),
            TeamKey.insert(withKey: "frc2", in: persistentContainer.viewContext)
        ]))
        cell.viewModel = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)

        // Test just having Teams, and a default Alliance
        XCTAssert(cell.levelLabel.isHidden)
        XCTAssertNil(cell.levelLabel.text)

        XCTAssertEqual(cell.nameLabel.text, "Alliance 2")

        // Snapshot
        verifyView(cell, identifier: "alliance_two_three_teams_no_status")

        alliance.name = "Alliance 3"
        cell.viewModel = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)

        XCTAssert(cell.levelLabel.isHidden)
        XCTAssertNil(cell.levelLabel.text)

        XCTAssertEqual(cell.nameLabel.text, "Alliance 3")

        var numberLabels = cell.allianceTeamsStackView.arrangedSubviews as! [UILabel]
        XCTAssertEqual(numberLabels.map({ $0.text }), ["1", "3", "2"])

        // Snapshot
        verifyView(cell, identifier: "alliance_three_three_teams_no_status")

        let status = EventStatusPlayoff.init(entity: EventStatusPlayoff.entity(), insertInto: persistentContainer.viewContext)
        status.level = "f"
        status.status = "won"
        alliance.status = status
        cell.viewModel = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)

        XCTAssertFalse(cell.levelLabel.isHidden)
        XCTAssertEqual(cell.levelLabel.text, "W")

        XCTAssertEqual(cell.nameLabel.text, "Alliance 3")

        // Snapshot
        verifyView(cell, identifier: "alliance_three_three_teams_status")

        alliance.addToPicks(TeamKey.insert(withKey: "frc4b", in: persistentContainer.viewContext))

        cell.viewModel = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)

        XCTAssertFalse(cell.levelLabel.isHidden)
        XCTAssertEqual(cell.levelLabel.text, "W")

        XCTAssertEqual(cell.nameLabel.text, "Alliance 3")

        numberLabels = cell.allianceTeamsStackView.arrangedSubviews as! [UILabel]
        XCTAssertEqual(numberLabels.map({ $0.text }), ["1", "3", "2", "4B"])

        // Snapshot
        verifyView(cell, identifier: "alliance_three_four_teams_status")
    }

    func test_gestureRecognizers() {
        let nib = EventAllianceTableViewCell.nib
        let cell = nib?.instantiate(withOwner: self, options: nil).first as! EventAllianceTableViewCell

        let alliance = EventAlliance.init(entity: EventAlliance.entity(), insertInto: persistentContainer.viewContext)
        alliance.addToPicks(NSOrderedSet(array: [
            TeamKey.insert(withKey: "frc1", in: persistentContainer.viewContext),
            TeamKey.insert(withKey: "frc3", in: persistentContainer.viewContext),
            TeamKey.insert(withKey: "frc2", in: persistentContainer.viewContext)
            ]))
        cell.viewModel = EventAllianceCellViewModel(alliance: alliance, allianceNumber: 2)

        let numberLabels = cell.allianceTeamsStackView.arrangedSubviews as! [UILabel]
        for (index, label) in numberLabels.enumerated() {
            XCTAssertEqual(label.tag, index)
            XCTAssertEqual(label.gestureRecognizers?.count, 1)
        }

        XCTAssert(cell.levelLabel.gestureRecognizers?.isEmpty ?? true)
        XCTAssert(cell.nameLabel.gestureRecognizers?.isEmpty ?? true)
    }

    // Test for teamTapped will need to happen in UI tests

}
