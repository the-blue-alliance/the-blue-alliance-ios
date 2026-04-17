import Foundation
import UIKit

class TeamHeaderView: UIView {

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

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, teamInfoStackView, yearStackView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

    private lazy var avatarImageView = AvatarImageView(baseColor: baseAvatarColor)

    private lazy var teamNumberLabel: UILabel = {
        let label = TeamHeaderView.teamHeaderLabel()
        let font = UIFont.preferredFont(forTextStyle: .title1)
        let fontMetrics = UIFontMetrics(forTextStyle: .title1)
        label.font = fontMetrics.scaledFont(for: UIFont.systemFont(ofSize: font.pointSize, weight: .semibold))
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private lazy var teamNameLabel: UILabel = {
        let label = TeamHeaderView.teamHeaderLabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
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

    init(_ viewModel: TeamHeaderViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        backgroundColor = UIColor.navigationBarTintColor
        clipsToBounds = true
        configureView()

        addSubview(rootStackView)
        rootStackView.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        rootStackView.autoPinEdge(toSuperviewSafeArea: .trailing, withInset: 16)
        rootStackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 16)
        rootStackView.autoSetDimension(.height, toSize: 55, relation: .greaterThanOrEqual)
        let topConstraint = rootStackView.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        // Allow our top spacing constraint to be unsatisfied - this will allow the view to glide under the navigation bar while scrolling
        topConstraint.priority = .defaultLow

        yearStackView.autoMatch(.height, to: .height, of: rootStackView)

        avatarImageView.autoSetDimensions(to: .init(width: 55, height: 55))
        avatarImageView.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private Methods

    private func configureView() {
        let newAvatar = viewModel.avatar
        let shouldHide = newAvatar == nil
        let avatarChanged = avatarImageView.image != newAvatar || avatarImageView.isHidden != shouldHide

        if window != nil, avatarChanged {
            UIView.transition(with: avatarImageView, duration: 0.25, options: .transitionCrossDissolve, animations: {
                self.avatarImageView.image = newAvatar
            })
            UIView.animate(withDuration: 0.25) {
                self.avatarImageView.isHidden = shouldHide
            }
        } else {
            avatarImageView.image = newAvatar
            avatarImageView.isHidden = shouldHide
        }

        teamNumberLabel.text = viewModel.teamNumberNickname

        teamNameLabel.text = viewModel.nickname
        teamNumberLabel.isHidden = viewModel.nickname == nil

        yearButton.year = viewModel.year
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
        layer.cornerRadius = 5

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
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

class YearButton: UIButton {

    // HIG minimum touch target (44pt) — expanded via hitTest so the visible
    // button stays compact without making the tappable area too small.
    private static let minimumTouchTarget: CGFloat = 44

    var year: Int? {
        didSet {
            var updated = configuration
            updated?.title = year.map(String.init) ?? "----"
            configuration = updated
        }
    }

    init() {
        super.init(frame: .zero)

        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = UIColor.navigationBarTintColor
        config.background.backgroundColor = UIColor.white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 8)
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 2
        config.title = "----"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            let base = UIFont.preferredFont(forTextStyle: .callout).pointSize
            outgoing.font = UIFont.monospacedDigitSystemFont(ofSize: base, weight: .bold)
            return outgoing
        }
        configuration = config

        configurationUpdateHandler = { button in
            var updated = button.configuration
            updated?.background.backgroundColor = button.isHighlighted ? UIColor.lightGray : UIColor.white
            button.configuration = updated
        }

        setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let dx = max(0, (Self.minimumTouchTarget - bounds.width) / 2)
        let dy = max(0, (Self.minimumTouchTarget - bounds.height) / 2)
        return bounds.insetBy(dx: -dx, dy: -dy).contains(point)
    }

}
