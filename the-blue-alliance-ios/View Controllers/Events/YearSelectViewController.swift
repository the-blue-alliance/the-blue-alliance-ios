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
    private var weeks: [Event] = [] {
        didSet {
            selectViewController.options = weeks
        }
    }
    private var hasRefreshed: Bool = false
    private let selectViewController: SelectTableViewController<EventWeekSelectViewController>

    weak var delegate: YearSelectViewControllerDelegate?

    init(year: Int, week: Event?, persistentContainer: NSPersistentContainer) {
        self.year = year

        selectViewController = SelectTableViewController<EventWeekSelectViewController>(current: week,
                                                                                        options: weeks,
                                                                                        persistentContainer: persistentContainer)

        super.init(viewControllers: [selectViewController],
                   persistentContainer: persistentContainer)

        title = "\(year) Weeks"
        selectViewController.delegate = self
        selectViewController.enableRefreshing()

        updateWeeks()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func updateWeeks() {
        weeks = Event.weekEvents(for: year, in: persistentContainer.viewContext)
        if isDataSourceEmpty && hasRefreshed {
            selectViewController.showNoDataView(with: "No weeks for \(year)")
        }
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

    var initialRefreshKey: String? {
        return "\(year)_events"
    }

    var isDataSourceEmpty: Bool {
        return weeks.isEmpty
    }

    func refresh() {
        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchEvents(year: year, completion: { (events, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh events - \(error.localizedDescription)")
            } else {
                // TODO: Fix this
                // self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                events?.forEach({ (modelEvent) in
                    Event.insert(with: modelEvent, in: backgroundContext)
                })

                backgroundContext.saveOrRollback()

                self.hasRefreshed = true
                self.updateWeeks()
                self.selectViewController.removeRequest(request: request!)
            })
        })
        selectViewController.addRequest(request: request!)
    }

}
