import Foundation
import PureLayout
import UIKit

/// The sections that don't fit in the tab bar beside the search pill.
class MoreViewController: UIViewController {

    private let items: [RootType]
    private let makeViewController: (RootType) -> UIViewController
    private let sponsorService: SponsorService
    private let urlOpener: any URLOpener
    private var displayedSponsors: [PlatinumSponsor] = []
    private var sponsorTask: Task<Void, Never>?

    private(set) lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    init(
        items: [RootType],
        sponsorService: SponsorService,
        urlOpener: any URLOpener,
        makeViewController: @escaping (RootType) -> UIViewController
    ) {
        self.items = items
        self.sponsorService = sponsorService
        self.urlOpener = urlOpener
        self.makeViewController = makeViewController

        super.init(nibName: nil, bundle: nil)

        title = RootType.more.title
        tabBarItem.image = RootType.more.icon
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // The navigation bar is transparent; the blue behind it is this view showing through.
        view.backgroundColor = UIColor.navigationBarTintColor

        view.addSubview(tableView)
        tableView.autoPinEdge(toSuperviewSafeArea: .top)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)

        // Rows grow with Dynamic Type, which moves the space left for the credit.
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (self: MoreViewController, _: UITraitCollection) in
            self.view.setNeedsLayout()
        }

        showSponsors(sponsorService.sponsors)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshSponsors()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sizeSponsorCredit()
    }

    // MARK: - Sponsors

    private func refreshSponsors() {
        sponsorTask?.cancel()
        let sponsorService = sponsorService
        sponsorTask = Task { [weak self] in
            let sponsors = await sponsorService.refresh()
            guard !Task.isCancelled else { return }
            self?.showSponsors(sponsors)
        }
    }

    /// The credit sits at the bottom of the screen, or directly below the last row when the
    /// rows leave no room, and is absent with no sponsors.
    private func showSponsors(_ sponsors: [PlatinumSponsor]) {
        guard sponsors != displayedSponsors else { return }
        displayedSponsors = sponsors
        guard !sponsors.isEmpty else {
            tableView.tableFooterView = nil
            return
        }
        let sponsorService = sponsorService
        let credit = SponsorCreditView(
            sponsors: sponsors,
            loadImage: { await sponsorService.image(for: $0) },
            onSelect: { [weak self] sponsor in self?.open(sponsor.url) }
        )
        credit.onContentSizeChange = { [weak self] in self?.view.setNeedsLayout() }
        tableView.tableFooterView = credit
        sizeSponsorCredit()
    }

    /// A table footer keeps whatever frame it's given, so it's resized by hand: tall enough
    /// to reach the bottom of the visible area, and never shorter than its content. Its top
    /// doesn't depend on its height, so resizing it can't feed back into the next pass.
    private func sizeSponsorCredit() {
        guard let credit = tableView.tableFooterView as? SponsorCreditView else { return }
        tableView.layoutIfNeeded()
        let width = tableView.bounds.width
        let insets = tableView.adjustedContentInset
        let height = Self.creditHeight(
            fitting: credit.sizeThatFits(
                CGSize(width: width, height: .greatestFiniteMagnitude)
            ).height,
            top: credit.frame.minY,
            visibleHeight: tableView.bounds.height - insets.top - insets.bottom
        )
        guard credit.frame.size != CGSize(width: width, height: height) else { return }
        credit.frame.size = CGSize(width: width, height: height)
        tableView.tableFooterView = credit
    }

    /// The footer fills from `top` down to the bottom of `visibleHeight`, but is never
    /// shorter than `fitting`, so long content just scrolls.
    static func creditHeight(
        fitting: CGFloat,
        top: CGFloat,
        visibleHeight: CGFloat
    ) -> CGFloat {
        max(fitting, (visibleHeight - top).rounded(.down))
    }

    private func open(_ url: URL) {
        if urlOpener.canOpenURL(url) {
            urlOpener.open(url)
        }
    }

}

extension MoreViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.image = item.icon
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

}

extension MoreViewController: UITableViewDelegate {

    // The tab bar inset settles after the first layout.
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        view.setNeedsLayout()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = makeViewController(items[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }

}
