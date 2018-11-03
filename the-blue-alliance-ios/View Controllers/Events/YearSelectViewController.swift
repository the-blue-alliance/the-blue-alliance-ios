import CoreData
import Foundation
import TBAKit
import UIKit

protocol YearSelectViewControllerDelegate: AnyObject {
    func weekEventSelected(_ weekEvent: Event)
}

class YearSelectViewController: ContainerViewController {

    private let year: Int
    private let week: Event?

    private let selectViewController: SelectTableViewController<YearSelectViewController>
    private var eventWeekSelectViewController: EventWeekSelectViewController?

    weak var delegate: YearSelectViewControllerDelegate? {
        didSet {
            eventWeekSelectViewController?.delegate = delegate
        }
    }

    // MARK: - Init

    init(year: Int, years: [Int], week: Event?, persistentContainer: NSPersistentContainer) {
        self.year = year
        self.week = week

        selectViewController = SelectTableViewController<YearSelectViewController>(current: year,
                                                                                   options: years,
                                                                                   willPush: true,
                                                                                   persistentContainer: persistentContainer)

        super.init(viewControllers: [selectViewController],
                   persistentContainer: persistentContainer)

        title = "Years"
        selectViewController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        eventWeekSelectViewController = EventWeekSelectViewController(year: year, week: week, persistentContainer: persistentContainer)
        eventWeekSelectViewController?.delegate = delegate

        navigationController?.viewControllers = [self, eventWeekSelectViewController!]

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
    }

    // MARK: - Private Methods

    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    private func pushToEventWeekSelect(year: Int) {
        eventWeekSelectViewController = EventWeekSelectViewController(year: year, week: week, persistentContainer: persistentContainer)
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

    init(year: Int, week: Event?, persistentContainer: NSPersistentContainer) {
        self.year = year

        let weeks = Event.weekEvents(for: year, in: persistentContainer.viewContext)

        selectViewController = WeeksSelectTableViewController(year: year,
                                                              current: week,
                                                              options: weeks,
                                                              persistentContainer: persistentContainer)

        super.init(viewControllers: [selectViewController],
                   persistentContainer: persistentContainer)

        title = "\(year) Weeks"
        selectViewController.delegate = self
        selectViewController.enableRefreshing()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    init(year: Int, current: Event?, options: [Event], persistentContainer: NSPersistentContainer) {
        self.year = year

        super.init(current: current, options: options, persistentContainer: persistentContainer)
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
        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEvents(year: year, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                if let events = events {
                    Event.insert(events, year: self.year, in: backgroundContext)

                    if backgroundContext.saveOrRollback() {
                        TBAKit.setLastModified(for: request!)
                    }
                }
                self.removeRequest(request: request!)

                self.hasRefreshed = true
                self.updateWeeks()
            })
        })
        addRequest(request: request!)
    }

    func updateWeeks() {
        options = Event.weekEvents(for: year, in: persistentContainer.viewContext)
        if isDataSourceEmpty && hasRefreshed {
            showNoDataView()
        }
    }
    
}

extension WeeksSelectTableViewController: Stateful {

    var noDataText: String {
        return "No weeks for year"
    }

}
