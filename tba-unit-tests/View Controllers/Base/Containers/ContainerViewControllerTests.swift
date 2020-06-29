import CoreData
import Foundation
import TBAKit
import XCTest
@testable import The_Blue_Alliance

class ContainerViewControllerTestCase: TBATestCase {

    var containerViewController: ContainerViewController!

    override func setUp() {
        super.setUp()

        let mockContainableViewController = MockContainableViewController(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        containerViewController = ContainerViewController(viewControllers: [mockContainableViewController], dependencies: dependencies)
    }

    override func tearDown() {
        containerViewController = nil

        super.tearDown()
    }

    func test_updateBarButtonItems() {
        XCTAssertEqual(containerViewController.navigationItem.rightBarButtonItems?.count, 1)
        containerViewController.rightBarButtonItems = [UIBarButtonItem(title: "Test", style: .plain, target: nil, action: nil)]
        XCTAssertEqual(containerViewController.navigationItem.rightBarButtonItems?.count, 2)
        containerViewController.rightBarButtonItems = [UIBarButtonItem(title: "Two", style: .plain, target: nil, action: nil)]
        XCTAssertEqual(containerViewController.navigationItem.rightBarButtonItems?.count, 2)
        containerViewController.rightBarButtonItems = []
        XCTAssertEqual(containerViewController.navigationItem.rightBarButtonItems?.count, 1)
    }

}


private class MockContainableViewController: ContainableViewController {

    var persistentContainer: NSPersistentContainer
    let tbaKit: TBAKit
    let userDefaults: UserDefaults

    // MARK: - Refreshable

    var refreshOperationQueue: OperationQueue = OperationQueue()
    var refreshControl: UIRefreshControl?
    var refreshView: UIScrollView {
        return UIScrollView()
    }
    var refreshKey: String?
    var automaticRefreshInterval: DateComponents?
    var automaticRefreshEndDate: Date?
    var isDataSourceEmpty: Bool = false

    // MARK: - Navigatable

    var additionalRightBarButtonItems: [UIBarButtonItem] {
        return [UIBarButtonItem(title: "Contained", style: .plain, target: nil, action: nil)]
    }

    // MARK: - Init

    init(persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refresh() {
        // Pass
    }

    func hideNoData() {
        // Pass
    }

    func noDataReload() {
        // Pass
    }

}
