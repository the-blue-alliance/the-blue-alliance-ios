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
        yearButton.autoSetDimension(.width, toSize: 60, relation: .greaterThanOrEqual)
        yearButton.autoSetDimension(.height, toSize: 30, relation: .greaterThanOrEqual)
        yearButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        return stackView
    }()

    init(_ viewModel: TeamHeaderViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        backgroundColor = UIColor.navigationBarTintColor
        configureView()

        addSubview(rootStackView)
        rootStackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), excludingEdge: .top)
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
        avatarImageView.image = viewModel.avatar
        avatarImageView.isHidden = viewModel.avatar == nil

        teamNumberLabel.text = viewModel.teamNumberNickname

        teamNameLabel.text = viewModel.nickname
        teamNumberLabel.isHidden = viewModel.nickname == nil

        let yearString: String = {
            if let year = viewModel.year {
                return String(year)
            } else {
                return "----"
            }
        }()
        yearButton.setTitle(yearString, for: .normal)
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

    override open var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.125) {
                self.backgroundColor = self.isHighlighted ? UIColor.lightGray : UIColor.white
            }
        }
    }

    init() {
        super.init(frame: .zero)

        tintColor = UIColor.navigationBarTintColor
        backgroundColor = UIColor.white

        setTitle("----", for: .normal)
        setTitleColor(UIColor.navigationBarTintColor, for: .normal)
        setImage(UIImage(systemName: "chevron.down"), for: .normal)
        setContentHuggingPriority(.defaultHigh, for: .horizontal)

        titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout, compatibleWith: nil).bold()

        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentEdgeInsets = UIEdgeInsets(top: 0, left: frame.size.height * 0.5, bottom: 0, right: frame.size.height * 0.5)

        layer.cornerRadius = frame.size.height * 0.5
    }

}
