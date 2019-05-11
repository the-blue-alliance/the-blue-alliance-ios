import Foundation
import UIKit

class TeamHeaderView: UIView {

    var viewModel: TeamHeaderViewModel {
        didSet {
            configureView()
        }
    }

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, teamInfoStackView, yearStackView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

    private let avatarImageView = AvatarImageView()

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

        backgroundColor = .primaryBlue
        configureView()

        addSubview(rootStackView)
        rootStackView.autoPinEdgesToSuperviewEdges(with: .init(top: 16, left: 16, bottom: 16, right: 16))
        yearStackView.autoMatch(.height, to: .height, of: rootStackView)
        rootStackView.autoSetDimension(.height, toSize: 55, relation: .greaterThanOrEqual)

        avatarImageView.autoSetDimensions(to: .init(width: 55, height: 55))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private Methods

    private func configureView() {
        avatarImageView.imageView.image = viewModel.avatar
        avatarImageView.isHidden = !viewModel.hasAvatar

        teamNumberLabel.text = viewModel.teamNumber

        teamNameLabel.text = viewModel.nickname
        teamNumberLabel.isHidden = !viewModel.hasNickname

        yearButton.setTitle(viewModel.year, for: .normal)
    }

    static func teamHeaderLabel() -> UILabel {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        return label
    }

    func changeAvatarBorder() {
        avatarImageView.avatarTapped()
    }

}

private class AvatarImageView: UIView {

    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        return imageView
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = .avatarBlue
        isUserInteractionEnabled = true

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: .init(top: 5, left: 5, bottom: 5, right: 5))

        layer.borderColor = UIColor.avatarBlue.cgColor
        layer.borderWidth = 5
        layer.masksToBounds = true
        layer.cornerRadius = 5

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private Methods

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

        tintColor = .primaryBlue
        backgroundColor = .white

        setTitle("----", for: .normal)
        setTitleColor(.primaryBlue, for: .normal)
        setImage(UIImage(named: "year_button_arrow_down"), for: .normal)
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
