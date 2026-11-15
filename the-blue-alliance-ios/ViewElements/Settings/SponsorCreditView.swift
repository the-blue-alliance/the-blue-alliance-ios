import UIKit

/// The platinum sponsor credit at the bottom of the More tab: a footnote over a wrapping row of
/// logos, styled like a section footer.
final class SponsorCreditView: UIView {

    static let itemSpacing: CGFloat = 16
    private static let topPadding: CGFloat = 8
    private static let titleSpacing: CGFloat = 10
    private static let bottomPadding: CGFloat = 24

    /// Called when a logo finishes loading and the credit needs a new height.
    var onContentSizeChange: (() -> Void)?

    let titleLabel = UILabel()
    let itemViews: [SponsorItemView]

    init(
        sponsors: [PlatinumSponsor],
        loadImage: @escaping (URL) async -> UIImage?,
        onSelect: @escaping (PlatinumSponsor) -> Void
    ) {
        itemViews = sponsors.map { SponsorItemView(sponsor: $0, loadImage: loadImage) }
        super.init(frame: .zero)

        preservesSuperviewLayoutMargins = true

        titleLabel.text = PlatinumSponsor.creditTitle(count: sponsors.count)
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .secondaryLabel
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)

        for item in itemViews {
            item.addAction(
                UIAction { [sponsor = item.sponsor] _ in onSelect(sponsor) },
                for: .touchUpInside
            )
            item.onContentSizeChange = { [weak self] in
                self?.setNeedsLayout()
                self?.onContentSizeChange?()
            }
            addSubview(item)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        CGSize(width: size.width, height: layout(width: size.width, apply: false))
    }

    /// Given more height than it needs, the credit sits at the bottom of it.
    override func layoutSubviews() {
        super.layoutSubviews()
        let needed = layout(width: bounds.width, apply: false)
        _ = layout(width: bounds.width, top: max(bounds.height - needed, 0), apply: true)
    }

    /// Lays the title out above the logos, wrapping logos onto new lines as needed, and
    /// returns the height used below `top`.
    private func layout(width: CGFloat, top: CGFloat = 0, apply: Bool) -> CGFloat {
        let left = layoutMargins.left
        let contentWidth = max(width - left - layoutMargins.right, 0)

        let titleSize = titleLabel.sizeThatFits(
            CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
        )
        var y = top + Self.topPadding
        if apply {
            titleLabel.frame = CGRect(x: left, y: y, width: contentWidth, height: titleSize.height)
        }
        y += titleSize.height + Self.titleSpacing

        var lines: [[(view: UIView, size: CGSize)]] = [[]]
        var lineWidth: CGFloat = 0
        for item in itemViews {
            let size = item.sizeThatFits(
                CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
            )
            let needed =
                lines[lines.count - 1].isEmpty
                ? size.width : lineWidth + Self.itemSpacing + size.width
            if needed > contentWidth, !lines[lines.count - 1].isEmpty {
                lines.append([(item, size)])
                lineWidth = size.width
            } else {
                lines[lines.count - 1].append((item, size))
                lineWidth = needed
            }
        }

        for (index, line) in lines.enumerated() {
            let lineHeight = line.map(\.size.height).max() ?? 0
            var x = left
            for (view, size) in line {
                if apply {
                    view.frame = CGRect(
                        x: x,
                        y: y + (lineHeight - size.height) / 2,
                        width: min(size.width, contentWidth),
                        height: size.height
                    )
                }
                x += size.width + Self.itemSpacing
            }
            y += lineHeight
            if index < lines.count - 1 {
                y += Self.itemSpacing / 2
            }
        }
        return y + Self.bottomPadding - top
    }

}

/// One sponsor: a wordmark on its own, a square mark beside the name, or just the name.
final class SponsorItemView: UIControl {

    static let logoHeight: CGFloat = 20
    private static let markSpacing: CGFloat = 6
    /// Logos dim in dark mode to sit at the same weight as the footnote, which is
    /// `secondaryLabel` (about 60% white).
    static let darkModeLogoAlpha: CGFloat = 0.6

    let sponsor: PlatinumSponsor
    let imageView = UIImageView()
    let nameLabel = UILabel()

    var onContentSizeChange: (() -> Void)?

    private let loadImage: (URL) async -> UIImage?
    private var loadTask: Task<Void, Never>?

    init(sponsor: PlatinumSponsor, loadImage: @escaping (URL) async -> UIImage?) {
        self.sponsor = sponsor
        self.loadImage = loadImage
        super.init(frame: .zero)

        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        addSubview(imageView)

        nameLabel.text = sponsor.name
        nameLabel.font = .preferredFont(forTextStyle: .footnote)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.textColor = .secondaryLabel
        nameLabel.numberOfLines = 0
        addSubview(nameLabel)

        isAccessibilityElement = true
        accessibilityLabel = sponsor.name
        accessibilityTraits = .link

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (self: SponsorItemView, _: UITraitCollection) in
            self.loadLogo()
        }
        loadLogo()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.5 : 1 }
    }

    /// The name shows until the logo loads, and stays if it never does. A mark keeps it beside
    /// the logo; a wordmark is the name, so the logo replaces it.
    private var showsName: Bool {
        sponsor.logoStyle == .mark || imageView.image == nil
    }

    private var logoSize: CGSize {
        guard let image = imageView.image, image.size.height > 0 else { return .zero }
        switch sponsor.logoStyle {
        case .mark:
            return CGSize(width: Self.logoHeight, height: Self.logoHeight)
        case .wordmark:
            return CGSize(
                width: Self.logoHeight * image.size.width / image.size.height,
                height: Self.logoHeight
            )
        }
    }

    /// A name too long for `size.width` wraps rather than truncating.
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let logo = logoSize
        guard showsName else { return logo }
        let name = nameSize(fitting: size.width)
        return CGSize(
            width: nameX + name.width,
            height: max(logo.height, name.height)
        )
    }

    private var nameX: CGFloat {
        logoSize.width > 0 ? logoSize.width + Self.markSpacing : 0
    }

    private func nameSize(fitting width: CGFloat) -> CGSize {
        nameLabel.sizeThatFits(
            CGSize(width: max(width - nameX, 0), height: .greatestFiniteMagnitude)
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let logo = logoSize
        imageView.frame = CGRect(
            x: 0,
            y: (bounds.height - logo.height) / 2,
            width: logo.width,
            height: logo.height
        )
        let nameSize = nameSize(fitting: bounds.width)
        nameLabel.frame = CGRect(
            x: nameX,
            y: (bounds.height - nameSize.height) / 2,
            width: max(bounds.width - nameX, 0),
            height: nameSize.height
        )
    }

    private func loadLogo() {
        let style = traitCollection.userInterfaceStyle
        imageView.alpha = style == .dark ? Self.darkModeLogoAlpha : 1
        loadTask?.cancel()
        guard let url = sponsor.logoURL(for: style) else { return }
        loadTask = Task { [weak self, loadImage] in
            let image = await loadImage(url)
            guard let self, !Task.isCancelled, let image else { return }
            self.setLogo(image)
        }
    }

    private func setLogo(_ image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        nameLabel.isHidden = !showsName
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        onContentSizeChange?()
    }

}
