import CoreData
import Crashlytics
import Firebase
import Foundation
import TBAData
import TBAKit
import UIKit

protocol YearSelectViewControllerDelegate: AnyObject {
    func weekEventSelected(_ weekEvent: Event)
}

class YearSelectViewController: ContainerViewController {

    private(set) var year: Int
    private(set) var years: [Int]
    private(set) var week: Event?

    private let selectViewController: SelectTableViewController<YearSelectViewController>
    private var eventWeekSelectViewController: EventWeekSelectViewController?

    weak var delegate: YearSelectViewControllerDelegate? {
        didSet {
            eventWeekSelectViewController?.delegate = delegate
        }
    }

    // MARK: - Init

    init(year: Int, years: [Int], week: Event?, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.year = year
        self.years = years
        self.week = week

        selectViewController = SelectTableViewController<YearSelectViewController>(current: year, options: years, willPush: true, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(viewControllers: [selectViewController], persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        title = "Years"

        selectViewController.delegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        selectViewController.disableRefreshing()

        eventWeekSelectViewController = EventWeekSelectViewController(year: year, week: week, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        eventWeekSelectViewController?.delegate = delegate

        navigationController?.viewControllers = [self, eventWeekSelectViewController!]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var parameters = ["year": NSNumber(value: year), "years": NSArray(array: years)]
        if let week = week {
            parameters["week"] = NSString(string: week.key!)
        }
        Analytics.logEvent("year_select", parameters: parameters)
    }

    // MARK: - Private Methods

    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func pushToEventWeekSelect(year: Int) {
        eventWeekSelectViewController = EventWeekSelectViewController(year: year, week: week, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        eventWeekSelectViewController?.delegate = delegate
        navigationController?.pushViewController(eventWeekSelectViewController!, animated: true)
    }

}

extension YearSelectViewController: SelectTableViewControllerDelegate {

    typealias OptionType = Int

    func optionSelected(_ option: OptionType) {
        pushToEventWeekSelect(year: option)
    }

    func titleForOption(_ option: OptionType) -> String {
        return String(option)
    }

}

private class EventWeekSelectViewController: ContainerViewController {

    private let year: Int
    private let selectViewController: WeeksSelectTableViewController

    weak var delegate: YearSelectViewControllerDelegate?

    init(year: Int, week: Event?, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.year = year

        let weeks = Event.weekEvents(for: year, in: persistentContainer.viewContext)

        selectViewController = WeeksSelectTableViewController(year: year,
                                                              current: week,
                                                              options: weeks,
                                                              persistentContainer: persistentContainer,
                                                              tbaKit: tbaKit,
                                                              userDefaults: userDefaults)

        super.init(viewControllers: [selectViewController], persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        title = "\(year) Weeks"

        selectViewController.delegate = self
        selectViewController.enableRefreshing()

        rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    @objc private func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

}

extension EventWeekSelectViewController: SelectTableViewControllerDelegate {

    typealias OptionType = Event

    func optionSelected(_ option: OptionType) {
        delegate?.weekEventSelected(option)
    }

    func titleForOption(_ option: OptionType) -> String {
        return option.weekString
    }

}

private class WeeksSelectTableViewController: SelectTableViewController<EventWeekSelectViewController> {

    private let year: Int

    fileprivate var hasRefreshed: Bool = false

    init(year: Int, current: Event?, options: [Event], persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.year = year

        super.init(current: current, options: options, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var refreshKey: String? {
        return "\(year)_events"
    }

    override var isDataSourceEmpty: Bool {
        return options.isEmpty
    }

    @objc override func refresh() {
        var operation: TBAKitOperation!
        operation = tbaKit.fetchEvents(year: year, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let events = try? result.get() {
                    Event.insert(events, year: self.year, in: context)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())

            self.hasRefreshed = true
            DispatchQueue.main.async {
                self.updateWeeks(in: self.persistentContainer.viewContext)
            }
        })
        addRefreshOperations([operation])
    }

    func updateWeeks(in context: NSManagedObjectContext) {
        options = Event.weekEvents(for: year, in: context)
        if isDataSourceEmpty && hasRefreshed {
            self.showNoDataView()
        }
    }
    
}

extension WeeksSelectTableViewController: Stateful {

    var noDataText: String {
        return "No weeks for year"
    }

}
