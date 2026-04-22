import Foundation
import TBAAPI
import UIKit

protocol YearSelectViewControllerDelegate: AnyObject {
    func weekEventSelected(_ weekEvent: Event)
}

class YearSelectViewController: ContainerViewController {

    private(set) var year: Int
    private(set) var years: [Int]
    private(set) var week: Event?

    private let selectViewController: SelectTableViewController<YearSelectViewController>

    weak var delegate: YearSelectViewControllerDelegate?

    // MARK: - Init

    init(year: Int, years: [Int], week: Event?, dependencies: Dependencies) {
        self.year = year
        self.years = years
        self.week = week

        selectViewController = SelectTableViewController<YearSelectViewController>(
            current: year,
            options: years,
            willPush: true,
            dependencies: dependencies
        )

        super.init(viewControllers: [selectViewController], dependencies: dependencies)

        title = "Years"

        selectViewController.delegate = self

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        selectViewController.disableRefreshing()

        let eventWeekSelectViewController = EventWeekSelectViewController(
            year: year,
            week: week,
            dependencies: dependencies
        )
        eventWeekSelectViewController.delegate = delegate

        navigationController?.viewControllers = [self, eventWeekSelectViewController]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var message = "Years: Year: \(year) | Years: \(years)"
        if let week = week {
            message.append(" | Week: \(week.key)")
        }
        dependencies.reporter.log(message)
    }

    // MARK: - Private Methods

    private func pushToEventWeekSelect(year: Int) {
        let eventWeekSelectViewController = EventWeekSelectViewController(
            year: year,
            week: week,
            dependencies: dependencies
        )
        eventWeekSelectViewController.delegate = delegate
        navigationController?.pushViewController(eventWeekSelectViewController, animated: true)
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

// MARK: - Inner week select

private class EventWeekSelectViewController: ContainerViewController {

    private let selectViewController: WeeksSelectTableViewController

    weak var delegate: YearSelectViewControllerDelegate?

    init(year: Int, week: Event?, dependencies: Dependencies) {
        selectViewController = WeeksSelectTableViewController(
            year: year,
            current: week,
            options: [],
            dependencies: dependencies
        )

        super.init(viewControllers: [selectViewController], dependencies: dependencies)

        title = "\(year) Weeks"

        selectViewController.delegate = self
        selectViewController.enableRefreshing()

        rightBarButtonItems = [
            UIBarButtonItem(
                systemItem: .done,
                primaryAction: UIAction { [weak self] _ in
                    self?.dismiss(animated: true)
                }
            )
        ]
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

private class WeeksSelectTableViewController: SelectTableViewController<
    EventWeekSelectViewController
>
{

    private let year: Int

    init(year: Int, current: Event?, options: [Event], dependencies: Dependencies) {
        self.year = year
        super.init(current: current, options: options, dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Refreshable

    override var isDataSourceEmpty: Bool { options.isEmpty }

    override func refresh() {
        runRefresh { [weak self] in
            guard let self else { return }
            let events = try await self.dependencies.api.eventsByYear(self.year)
            self.options = WeekEventsGrouping.weekEvents(for: self.year, from: events)
            if self.isDataSourceEmpty {
                self.showNoDataView()
            }
        }
    }
}

extension WeeksSelectTableViewController: Stateful {

    var noDataText: String? {
        return "No weeks for year"
    }

}
