#if DEBUG
    import Foundation
    import TBAAPI
    import UIKit

    private enum DebugSection: Int, CaseIterable {
        case scenario
        case follows
        case result
    }

    private enum FollowsRow: Int, CaseIterable {
        case teams
        case events
        case signedIn
    }

    /// Picks a date and follows for the Dashboard, then shows what the feed builder makes of
    /// them. Presented from the Dashboard's debug bar button.
    class DashboardDebugViewController: TBATableViewController {

        private let overrides: DashboardDebugOverrides
        private let onChange: () -> Void

        private var phase: DashboardPhase?
        private var cards: [DashboardCard] = []
        private var loadTask: Task<Void, Never>?
        private var loadSummary = "Not loaded"

        private lazy var datePicker: UIDatePicker = {
            let picker = UIDatePicker()
            picker.datePickerMode = .dateAndTime
            picker.preferredDatePickerStyle = .compact
            picker.addAction(
                UIAction { [weak self] action in
                    guard let picker = action.sender as? UIDatePicker else { return }
                    self?.overrides.now = picker.date
                    self?.overridesChanged()
                },
                for: .valueChanged
            )
            return picker
        }()

        init(
            overrides: DashboardDebugOverrides,
            onChange: @escaping () -> Void,
            dependencies: Dependencies
        ) {
            self.overrides = overrides
            self.onChange = onChange

            super.init(style: .insetGrouped, dependencies: dependencies)

            title = "Dashboard Inspector"
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                systemItem: .done,
                primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
            )
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            tableView.contentInsetAdjustmentBehavior = .automatic
            load()
        }

        // MARK: - Loading

        private func overridesChanged() {
            tableView.reloadData()
            onChange()
            load()
        }

        private func load() {
            loadTask?.cancel()
            navigationItem.leftBarButtonItem = UIBarButtonItem.activityIndicatorBarButtonItem()
            loadTask = Task { [weak self] in
                guard let self else { return }
                let started = Date()
                let result = await DashboardFeedBuilder(api: dependencies.api).load(
                    follows: overrides.effectiveFollows(favorites: myTBAStores.favorites),
                    status: statusService.status,
                    isSignedIn: overrides.effectiveSignedIn(authService: dependencies.authService),
                    now: overrides.effectiveNow()
                )
                guard !Task.isCancelled else { return }
                phase = result.phase
                cards = result.cards
                let elapsed = Date().timeIntervalSince(started)
                loadSummary =
                    "\(cards.count) cards in \(elapsed.formatted(.number.precision(.fractionLength(2)))) s"
                navigationItem.leftBarButtonItem = nil
                tableView.reloadSections(
                    IndexSet(integer: DebugSection.result.rawValue),
                    with: .none
                )
            }
        }

        // MARK: - Table View Data Source

        override func numberOfSections(in tableView: UITableView) -> Int {
            DebugSection.allCases.count
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
            -> Int
        {
            switch DebugSection(rawValue: section)! {
            case .scenario: return DashboardDebugOverrides.scenarios.count + 1
            case .follows: return FollowsRow.allCases.count
            case .result: return 1 + cards.count
            }
        }

        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
            -> String?
        {
            switch DebugSection(rawValue: section)! {
            case .scenario: return "Pretend it's"
            case .follows: return "Follows"
            case .result: return "Feed"
            }
        }

        override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int)
            -> String?
        {
            switch DebugSection(rawValue: section)! {
            case .scenario: return nil
            case .follows: return "Leave teams and events empty to use your myTBA favorites."
            case .result: return loadSummary
            }
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
            -> UITableViewCell
        {
            switch DebugSection(rawValue: indexPath.section)! {
            case .scenario: return scenarioCell(at: indexPath.row)
            case .follows: return followsCell(for: FollowsRow(rawValue: indexPath.row)!)
            case .result: return resultCell(at: indexPath.row)
            }
        }

        private func scenarioCell(at row: Int) -> UITableViewCell {
            let scenarios = DashboardDebugOverrides.scenarios
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            if row < scenarios.count {
                let scenario = scenarios[row]
                cell.textLabel?.text = scenario.title
                cell.accessoryType = overrides.now == scenario.now ? .checkmark : .none
            } else {
                cell.textLabel?.text = "Custom"
                cell.selectionStyle = .none
                datePicker.date = overrides.now ?? Date()
                cell.accessoryView = datePicker
                let isCustom =
                    overrides.now.map { now in !scenarios.contains { $0.now == now } } ?? false
                cell.textLabel?.textColor = isCustom ? .label : .secondaryLabel
            }
            return cell
        }

        private func followsCell(for row: FollowsRow) -> UITableViewCell {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = .none
            switch row {
            case .teams:
                cell.textLabel?.text = "Teams"
                cell.accessoryView = textField(
                    text: overrides.teamKeys?.map { $0.trimPrefix }.joined(separator: ", "),
                    placeholder: "254, 1678",
                    keyboard: .numbersAndPunctuation
                ) { [weak self] text in
                    self?.overrides.teamKeys = DashboardDebugOverrides.teamKeys(from: text)
                }
            case .events:
                cell.textLabel?.text = "Events"
                cell.accessoryView = textField(
                    text: overrides.eventKeys?.joined(separator: ", "),
                    placeholder: "2026casj",
                    keyboard: .asciiCapable
                ) { [weak self] text in
                    self?.overrides.eventKeys = DashboardDebugOverrides.eventKeys(from: text)
                }
            case .signedIn:
                cell.textLabel?.text = "Signed in"
                let toggle = UISwitch()
                toggle.isOn = overrides.effectiveSignedIn(authService: dependencies.authService)
                toggle.addAction(
                    UIAction { [weak self] action in
                        guard let toggle = action.sender as? UISwitch else { return }
                        self?.overrides.signedIn = toggle.isOn
                        self?.overridesChanged()
                    },
                    for: .valueChanged
                )
                cell.accessoryView = toggle
            }
            return cell
        }

        private func textField(
            text: String?,
            placeholder: String,
            keyboard: UIKeyboardType,
            commit: @escaping (String) -> Void
        ) -> UITextField {
            let field = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 32))
            field.text = text
            field.placeholder = placeholder
            field.textAlignment = .right
            field.keyboardType = keyboard
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.returnKeyType = .done
            field.clearButtonMode = .whileEditing
            field.addAction(
                UIAction { [weak self] action in
                    guard let field = action.sender as? UITextField else { return }
                    field.resignFirstResponder()
                    commit(field.text ?? "")
                    self?.overridesChanged()
                },
                for: [.editingDidEnd, .editingDidEndOnExit]
            )
            return field
        }

        private func resultCell(at row: Int) -> UITableViewCell {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.selectionStyle = .none
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.textColor = .secondaryLabel
            if row == 0 {
                cell.textLabel?.text = "Phase"
                cell.detailTextLabel?.text = phase.map(Self.describe) ?? "…"
            } else {
                let (title, detail) = Self.describe(cards[row - 1])
                cell.textLabel?.text = "\(row). \(title)"
                cell.detailTextLabel?.text = detail
            }
            return cell
        }

        // MARK: - Table View Delegate

        // Keep the standard grouped headers; the base class paints the app's plain-table bands.
        override func tableView(
            _ tableView: UITableView,
            willDisplayHeaderView view: UIView,
            forSection section: Int
        ) {}

        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            guard DebugSection(rawValue: indexPath.section) == .scenario,
                indexPath.row < DashboardDebugOverrides.scenarios.count
            else { return }
            overrides.now = DashboardDebugOverrides.scenarios[indexPath.row].now
            overridesChanged()
        }

        // MARK: - Descriptions

        private static func describe(_ phase: DashboardPhase) -> String {
            switch phase {
            case .offseason(let season):
                return "Offseason · \(season) is over"
            case .preKickoff(let season, let kickoff):
                return "Countdown to \(season) kickoff · \(kickoff.formatted(dateTime))"
            case .kickoff(let season, let kickoff):
                return "Kickoff day · \(season) · \(kickoff.formatted(dateTime))"
            case .buildSeason(let season, let firstEventStart):
                let first = firstEventStart?.formatted(eventDay) ?? "unknown"
                return "Build season · \(season) · first event \(first)"
            case .competition(let season, let week, let weekLabel, let totalWeeks):
                return "\(weekLabel) of \(totalWeeks) (index \(week)) · \(season)"
            case .championship(let season):
                return "Championship · \(season)"
            }
        }

        private static func describe(_ card: DashboardCard) -> (String, String) {
            switch card {
            case .teamAtEvent(let hero):
                var lines = [hero.event.key]
                if let ranking = hero.status?.qual?.ranking, let rank = ranking.rank {
                    var line = "Rank \(rank) of \(hero.status?.qual?.numTeams ?? 0)"
                    if let record = ranking.record {
                        line += " · \(record.wins)-\(record.losses)-\(record.ties)"
                    }
                    lines.append(line)
                }
                if let next = hero.nextMatch {
                    lines.append(
                        "Next: \(next.friendlyName(playoffType: hero.event.playoffTypeEnum)) \(next.startTimeString ?? "")"
                    )
                }
                if let last = hero.lastMatch {
                    lines.append(
                        "Last: \(last.friendlyName(playoffType: hero.event.playoffTypeEnum)) · \(last.winningAllianceString.isEmpty ? "no result" : "\(last.winningAllianceString) won")"
                    )
                }
                if let alliance = hero.status?.allianceStatusStr, alliance != "--" {
                    lines.append(
                        alliance.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(
                            of: "</b>",
                            with: ""
                        )
                    )
                }
                return (
                    "Hero · \(hero.team.teamNumber) \(hero.team.displayNickname)",
                    lines.joined(separator: "\n")
                )
            case .followedEventLive(let live):
                let rows = live.rankings.map { row in
                    let mark = live.followedTeamKeys.contains(row.teamKey) ? "★ " : ""
                    return "\(row.rank). \(mark)\(row.teamKey.trimPrefix)"
                }
                let alliances = live.alliances.map { "\($0.count) alliances" } ?? "no alliances yet"
                return ("Live · \(live.event.key)", (rows + [alliances]).joined(separator: "\n"))
            case .upNext(let upNext):
                let lines = upNext.entries.map { entry in
                    let who = entry.team.map { "\($0.teamNumber) → " } ?? ""
                    return "\(who)\(entry.event.key) · \(entry.event.dateString ?? "")"
                }
                return ("Up next", lines.joined(separator: "\n"))
            case .recentResults(let recent):
                let lines = recent.entries.map { entry in
                    "\(entry.team.teamNumber) · \(entry.match.key) · \(entry.match.winningAllianceString.isEmpty ? "no result" : "\(entry.match.winningAllianceString) won")"
                }
                return ("Recent results", lines.joined(separator: "\n"))
            case .thisWeekEvents(let week):
                return (
                    "This week · \(week.events.count) events",
                    week.events.map(\.key).joined(separator: ", ")
                )
            case .season(let phase):
                return ("Season", describe(phase))
            case .getStarted(let signedIn):
                return ("Get started", signedIn ? "Signed in, no favorites" : "Signed out")
            }
        }

        private static let dateTime = Date.FormatStyle().month(.abbreviated).day().year().hour()
            .minute()
        private static let eventDay = Date.FormatStyle(timeZone: .gmt).month(.abbreviated).day()

    }
#endif
