import Foundation
import SkeletonView
import UIKit

class TeamHeaderView: UIView {

    // MARK: Shared geometry / fonts
    //
    // Both the real subviews and their skeleton counterparts read from this
    // single source — change a value here and both stay aligned, so the two
    // parallel hierarchies can't drift on their own.

    fileprivate static let avatarSize: CGSize = .init(width: 55, height: 55)
    fileprivate static let avatarCornerRadius: CGFloat = 5
    fileprivate static let yearPillSize: CGSize = .init(width: 84, height: 28)
    fileprivate static var yearPillCornerRadius: CGFloat { yearPillSize.height / 2 }
    fileprivate static let headerStackSpacing: CGFloat = 8

    fileprivate static func teamNumberFont() -> UIFont {
        let font = UIFont.preferredFont(forTextStyle: .title1)
        let metrics = UIFontMetrics(forTextStyle: .title1)
        return metrics.scaledFont(
            for: UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)
        )
    }

    fileprivate static func teamNameFont() -> UIFont {
        UIFont.preferredFont(forTextStyle: .title3)
    }

    // Median nickname length across all 3,729 FRC teams with a nickname in
    // 2026 (TBA data, computed via `tba team list --year 2026`). Mean was
    // pulled up by sponsor-list nicknames; mode was a noisy tie. Used to
    // size the subtitle skeleton so it looks "right" for the typical team.
    fileprivate static let medianTeamNameLength = 13

    fileprivate static func skeletonSubtitleWidth() -> CGFloat {
        // Measure with lowercase 'a' as a neutral-width stand-in (M would
        // overshoot, i would undershoot). Re-measured per call so dynamic
        // type changes propagate.
        let sample = String(repeating: "a", count: medianTeamNameLength)
        let width = (sample as NSString).size(
            withAttributes: [.font: teamNameFont()]
        ).width
        return ceil(width)
    }

    var viewModel: TeamHeaderViewModel {
        didSet {
            configureView()
        }
    }
    private var baseAvatarColor: UIColor {
        // Some teams look better in Red, some teams look better in Blue.
        // One team looks better in Black.
        if viewModel.teamNumber == 148 {
            return UIColor.black
        }
        let redTeams = [1114, 2337]
        if redTeams.contains(viewModel.teamNumber) {
            return UIColor.avatarRed
        }
        return UIColor.avatarBlue
    }

    // MARK: Real content

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            avatarImageView, teamInfoStackView, yearStackView,
        ])
        stackView.axis = .horizontal
        stackView.spacing = Self.headerStackSpacing
        stackView.alignment = .center
        return stackView
    }()

    private lazy var avatarImageView = AvatarImageView(baseColor: baseAvatarColor)

    private lazy var teamNumberLabel: UILabel = {
        let label = TeamHeaderView.teamHeaderLabel()
        label.font = Self.teamNumberFont()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private lazy var teamNameLabel: UILabel = {
        let label = TeamHeaderView.teamHeaderLabel()
        label.font = Self.teamNameFont()
        label.numberOfLines = 0
        return label
    }()
    private lazy var teamInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [teamNumberLabel, teamNameLabel])
        stackView.axis = .vertical
        return stackView
    }()

    let yearButton = YearButton()
    private lazy var yearStackView: UIStackView = {
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)

        let stackView = UIStackView(arrangedSubviews: [spacerView, yearButton])
        stackView.axis = .vertical
        stackView.alignment = .trailing
        yearButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        yearButton.setContentHuggingPriority(.required, for: .vertical)
        return stackView
    }()

    // MARK: Skeleton overlay
    //
    // A parallel stack mirroring rootStackView, drawn on top while data loads.
    // Real subviews stay laid out at their final positions underneath (alpha 0)
    // so when we cross-fade to them they don't reflow / grow in.

    private lazy var skeletonAvatar: UIView = {
        let v = UIView()
        v.isSkeletonable = true
        v.skeletonCornerRadius = Float(Self.avatarCornerRadius)
        v.autoSetDimensions(to: Self.avatarSize)
        return v
    }()

    // Invisible label sized like teamNumberLabel — reserves vertical space in
    // the skeleton info stack so the subtitle bar lands where teamNameLabel
    // will end up. Team number is known at init, so the real label stays
    // visible throughout loading and never needs a skeleton placeholder.
    private lazy var skeletonNumberSpacer: UILabel = {
        let label = TeamHeaderView.teamHeaderLabel()
        label.font = Self.teamNumberFont()
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .clear
        return label
    }()

    private lazy var skeletonSubtitleBar: UIView = {
        let v = UIView()
        v.isSkeletonable = true
        v.skeletonCornerRadius = 4
        v.autoSetDimension(.height, toSize: 16)
        v.autoSetDimension(.width, toSize: Self.skeletonSubtitleWidth())
        return v
    }()

    // Wraps skeletonSubtitleBar in a slot whose intrinsic height matches
    // teamNameLabel (title3). The bar is leading-pinned + vertically centered
    // inside, so it stays narrow even when skeletonInfoStack uses the same
    // .fill alignment as the real teamInfoStackView.
    private lazy var skeletonSubtitleSlot: UIView = {
        let container = UIView()

        let measuringLabel = UILabel()
        measuringLabel.font = Self.teamNameFont()
        measuringLabel.text = " "
        measuringLabel.textColor = .clear
        container.addSubview(measuringLabel)
        measuringLabel.autoPinEdgesToSuperviewEdges()

        container.addSubview(skeletonSubtitleBar)
        skeletonSubtitleBar.autoPinEdge(toSuperviewEdge: .leading)
        skeletonSubtitleBar.autoAlignAxis(toSuperviewAxis: .horizontal)

        container.isSkeletonable = true
        return container
    }()

    // Mirrors teamInfoStackView: vertical axis, default alignment (.fill),
    // default spacing (0). With that match, skeletonNumberSpacer +
    // skeletonSubtitleSlot land at the same vertical positions as
    // teamNumberLabel + teamNameLabel will.
    private lazy var skeletonInfoStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [skeletonNumberSpacer, skeletonSubtitleSlot])
        s.axis = .vertical
        s.isSkeletonable = true
        return s
    }()

    private lazy var skeletonYearPill: UIView = {
        let v = UIView()
        v.isSkeletonable = true
        v.skeletonCornerRadius = Float(Self.yearPillCornerRadius)
        // Sized for "YYYY" + chevron + YearButton's content insets — the year
        // is always 4 digits, so this matches the real button to within a
        // pixel and avoids a width snap when the real button replaces it.
        v.autoSetDimensions(to: Self.yearPillSize)
        return v
    }()

    // Mirrors yearStackView: spacer-on-top pushes the pill to the bottom so
    // it aligns with the real yearButton (which sits at the bottom of its
    // height-matched stack).
    private lazy var skeletonYearStack: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        let s = UIStackView(arrangedSubviews: [spacer, skeletonYearPill])
        s.axis = .vertical
        s.alignment = .trailing
        s.isSkeletonable = true
        return s
    }()

    private lazy var skeletonStackView: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let s = UIStackView(arrangedSubviews: [
            skeletonAvatar, skeletonInfoStack, spacer, skeletonYearStack,
        ])
        s.axis = .horizontal
        s.spacing = Self.headerStackSpacing
        s.alignment = .center
        s.isSkeletonable = true
        s.isHidden = true
        return s
    }()

    // Standalone overlay pinned to avatarImageView for the year-change
    // skeleton — skeletonStackView is hidden after the initial load, so its
    // skeletonAvatar can't be reused for subsequent avatar loads.
    private lazy var avatarSkeletonOverlay: UIView = {
        let v = UIView()
        v.isSkeletonable = true
        v.skeletonCornerRadius = Float(Self.avatarCornerRadius)
        v.isHidden = true
        return v
    }()

    // Lighter wash so the skeleton reads against the navy header background.
    private static let skeletonGradient = SkeletonGradient(
        baseColor: UIColor(white: 1.0, alpha: 0.22)
    )

    init(_ viewModel: TeamHeaderViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        backgroundColor = UIColor.navigationBarTintColor
        clipsToBounds = true
        configureView()

        isSkeletonable = true

        addSubview(rootStackView)
        rootStackView.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        rootStackView.autoPinEdge(toSuperviewSafeArea: .trailing, withInset: 16)
        rootStackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        rootStackView.autoSetDimension(.height, toSize: 55, relation: .greaterThanOrEqual)
        let topConstraint = rootStackView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        // Allow our top spacing constraint to be unsatisfied - this will allow the view to glide under the navigation bar while scrolling
        topConstraint.priority = .defaultLow

        yearStackView.autoMatch(.height, to: .height, of: rootStackView)

        avatarImageView.autoSetDimensions(to: Self.avatarSize)
        avatarImageView.setContentCompressionResistancePriority(.required, for: .vertical)

        addSubview(skeletonStackView)
        skeletonStackView.autoPinEdge(.leading, to: .leading, of: rootStackView)
        skeletonStackView.autoPinEdge(.trailing, to: .trailing, of: rootStackView)
        skeletonStackView.autoPinEdge(.top, to: .top, of: rootStackView)
        skeletonStackView.autoPinEdge(.bottom, to: .bottom, of: rootStackView)
        skeletonYearStack.autoMatch(.height, to: .height, of: skeletonStackView)

        addSubview(avatarSkeletonOverlay)
        avatarSkeletonOverlay.autoPinEdge(.leading, to: .leading, of: avatarImageView)
        avatarSkeletonOverlay.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        avatarSkeletonOverlay.autoPinEdge(.top, to: .top, of: avatarImageView)
        avatarSkeletonOverlay.autoPinEdge(.bottom, to: .bottom, of: avatarImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private Methods

    private func configureView() {
        // Avatar is intentionally NOT touched here — it's driven by the
        // explicit avatar API (setAvatar / transitionAvatar / hide…Skeleton)
        // so callers can coordinate slot-collapse animations with the
        // skeleton cross-fade. configureView fires from viewModel didSet
        // synchronously and would otherwise jump the layout mid-animation.
        teamNumberLabel.text = viewModel.teamNumberNickname
        teamNameLabel.text = viewModel.nickname
        teamNameLabel.isHidden = viewModel.nickname == nil

        yearButton.year = viewModel.year
    }

    // MARK: Avatar API
    //
    // Slot reservation rules:
    //   - avatarImageView.isHidden == false → 55×55 slot in rootStackView.
    //   - avatarImageView.isHidden == true  → slot collapses, labels shift left.
    // All four transitions (nil↔image, image↔image, etc.) go through
    // transitionAvatar so the slot collapse/expand stays animated and in sync
    // with whatever skeleton animation the caller is running.

    func setAvatar(_ image: UIImage?) {
        avatarImageView.image = image
        avatarImageView.isHidden = image == nil
    }

    func transitionAvatar(to image: UIImage?) {
        let oldImage = avatarImageView.image
        switch (oldImage, image) {
        case (nil, nil):
            return
        case (.some, .some):
            UIView.transition(
                with: avatarImageView,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: { self.avatarImageView.image = image }
            )
        case (nil, .some):
            avatarImageView.image = image
            avatarImageView.isHidden = false
            avatarImageView.alpha = 0
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self.avatarImageView.alpha = 1
                    self.layoutIfNeeded()
                }
            )
        case (.some, nil):
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self.avatarImageView.alpha = 0
                    self.avatarImageView.isHidden = true
                    self.layoutIfNeeded()
                },
                completion: { _ in
                    self.avatarImageView.image = nil
                    self.avatarImageView.alpha = 1
                }
            )
        }
    }

    // MARK: Skeleton API

    func showLoadingSkeleton() {
        // Mirror the (already-known) team number into the spacer so the
        // skeleton info stack matches teamInfoStackView's height exactly.
        skeletonNumberSpacer.text = viewModel.teamNumberNickname

        // Reserve the avatar/nickname slots so rootStackView's layout matches
        // the skeleton overlay's. Without this, an init-time-nil avatar or
        // nickname leaves teamNumberLabel flush against the leading edge
        // while the skeleton avatar sits beside it.
        avatarImageView.isHidden = false
        avatarImageView.alpha = 0
        teamNameLabel.isHidden = false

        // If we were pushed with a full Team (nickname known at init), skip
        // the subtitle skeleton and keep the real label visible — there's
        // nothing to load. Slot height stays reserved by skeletonSubtitleSlot's
        // measuring label either way, so the skeleton stack still aligns.
        let hasNickname = viewModel.nickname != nil
        skeletonSubtitleBar.isHidden = hasNickname
        teamNameLabel.alpha = hasNickname ? 1 : 0

        let hasYear = viewModel.year != nil
        skeletonYearPill.isHidden = hasYear
        yearButton.alpha = hasYear ? 1 : 0

        // When the nickname is unknown, give teamNameLabel a single-space
        // placeholder so it claims its title3 intrinsic height. Without this
        // the info stack collapses to just teamNumberLabel's height; centered
        // in rootStackView it sits ~12pt low, then jumps up when the real
        // nickname lands and grows the stack. configureView overwrites the
        // " " with the real text on load.
        if !hasNickname {
            teamNameLabel.text = " "
        }

        skeletonStackView.isHidden = false
        skeletonStackView.showAnimatedGradientSkeleton(
            usingGradient: Self.skeletonGradient
        )
    }

    func hideLoadingSkeleton(revealing avatar: UIImage?) {
        // Caller is expected to update viewModel (text fields) BEFORE calling
        // this so the real subviews have their final sizes already laid out
        // under the still-visible skeleton. The avatar IS set here so its
        // slot collapse/expand animates in sync with the skeleton fade.
        skeletonStackView.hideSkeleton(reloadDataAfter: false)
        avatarImageView.image = avatar
        let willHaveAvatar = avatar != nil

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.skeletonStackView.alpha = 0
                self.teamNameLabel.alpha = 1
                self.yearButton.alpha = 1
                if willHaveAvatar {
                    self.avatarImageView.isHidden = false
                    self.avatarImageView.alpha = 1
                } else {
                    self.avatarImageView.alpha = 0
                    self.avatarImageView.isHidden = true
                }
                self.layoutIfNeeded()
            },
            completion: { _ in
                self.skeletonStackView.isHidden = true
                self.skeletonStackView.alpha = 1
                if !willHaveAvatar {
                    self.avatarImageView.alpha = 1  // reset for future reveals
                }
            }
        )
    }

    func showAvatarSkeleton() {
        avatarImageView.alpha = 0
        avatarSkeletonOverlay.isHidden = false
        avatarSkeletonOverlay.showAnimatedGradientSkeleton(
            usingGradient: Self.skeletonGradient
        )
    }

    func hideAvatarSkeleton(revealing avatar: UIImage?) {
        avatarSkeletonOverlay.hideSkeleton(reloadDataAfter: false)
        avatarImageView.image = avatar
        let willHaveAvatar = avatar != nil

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.avatarSkeletonOverlay.alpha = 0
                if willHaveAvatar {
                    self.avatarImageView.isHidden = false
                    self.avatarImageView.alpha = 1
                } else {
                    self.avatarImageView.alpha = 0
                    self.avatarImageView.isHidden = true
                }
                self.layoutIfNeeded()
            },
            completion: { _ in
                self.avatarSkeletonOverlay.isHidden = true
                self.avatarSkeletonOverlay.alpha = 1
                if !willHaveAvatar {
                    self.avatarImageView.alpha = 1
                }
            }
        )
    }

    static func teamHeaderLabel() -> UILabel {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white
        return label
    }

    func changeAvatarBorder() {
        avatarImageView.avatarTapped()
    }

}

private class AvatarImageView: UIView {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()

    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    init(baseColor: UIColor) {
        super.init(frame: .zero)

        backgroundColor = baseColor
        isUserInteractionEnabled = true

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: .init(top: 5, left: 5, bottom: 5, right: 5))

        layer.borderColor = baseColor.cgColor
        layer.borderWidth = 5
        layer.masksToBounds = true
        layer.cornerRadius = TeamHeaderView.avatarCornerRadius

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(avatarTapped)
        )
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Methods

    @objc func avatarTapped() {
        let newColor = backgroundColor == .avatarBlue ? UIColor.avatarRed : UIColor.avatarBlue
        backgroundColor = newColor
        layer.borderColor = newColor.cgColor
    }

}

class YearButton: UIControl {

    private static let minimumTouchTarget: CGFloat = 44

    private let label: UILabel = {
        let label = UILabel()
        let base = UIFont.preferredFont(forTextStyle: .callout).pointSize
        label.font = UIFont.monospacedDigitSystemFont(ofSize: base, weight: .bold)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.navigationBarTintColor
        label.text = "----"
        return label
    }()

    private let chevronView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(
                systemName: "chevron.down",
                withConfiguration: UIImage.SymbolConfiguration(
                    textStyle: .callout,
                    scale: .small
                )
            )
        )
        imageView.tintColor = UIColor.navigationBarTintColor
        imageView.contentMode = .center
        return imageView
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = UIColor.navigationBarTintColor
        spinner.hidesWhenStopped = false
        spinner.isHidden = true
        return spinner
    }()

    private let trailingContainer = TrailingContainerView()

    var year: Int? {
        didSet { label.text = year.map(String.init) ?? "----" }
    }

    var isLoading: Bool = false {
        didSet {
            guard isLoading != oldValue else { return }
            chevronView.isHidden = isLoading
            spinner.isHidden = !isLoading
            if isLoading {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }

    init() {
        super.init(frame: .zero)

        backgroundColor = UIColor.white
        layer.masksToBounds = true

        for child in [chevronView, spinner] as [UIView] {
            child.translatesAutoresizingMaskIntoConstraints = false
            trailingContainer.addSubview(child)
            NSLayoutConstraint.activate([
                child.centerXAnchor.constraint(equalTo: trailingContainer.centerXAnchor),
                child.centerYAnchor.constraint(equalTo: trailingContainer.centerYAnchor),
            ])
        }

        let stack = UIStackView(arrangedSubviews: [label, trailingContainer])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])

        setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let dx = max(0, (Self.minimumTouchTarget - bounds.width) / 2)
        let dy = max(0, (Self.minimumTouchTarget - bounds.height) / 2)
        return bounds.insetBy(dx: -dx, dy: -dy).contains(point)
    }

}

private final class TrailingContainerView: UIView {
    override var intrinsicContentSize: CGSize {
        var size = CGSize.zero
        for sub in subviews {
            let s = sub.intrinsicContentSize
            size.width = max(size.width, s.width)
            size.height = max(size.height, s.height)
        }
        return size
    }
}
