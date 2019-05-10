import Foundation
import UIKit

class TeamHeaderView: UIView {

    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, teamInfoStackView, yearStackView])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

    private let avatarImageView = AvatarImageView(data: nil)

    private lazy var teamNumberLabel: UILabel = {
        let label = TeamHeaderView.teamHeaderLabel()
        let font = UIFont.preferredFont(forTextStyle: .title1)
        let fontMetrics = UIFontMetrics(forTextStyle: .title1)
        label.font = fontMetrics.scaledFont(for: UIFont.systemFont(ofSize: font.pointSize, weight: .semibold))
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

    private let yearButton = YearButton()
    private lazy var yearStackView: UIStackView = {
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .vertical)

        let stackView = UIStackView(arrangedSubviews: [spacerView, yearButton])
        stackView.axis = .vertical
        return stackView
    }()

    // TODO: Should probably just take an Avatar, or should set Avatar not on init
    init(team: Team, year: Int?) {
        super.init(frame: .zero)

        backgroundColor = .primaryBlue

        addSubview(rootStackView)
        rootStackView.autoPinEdgesToSuperviewEdges(with: .init(top: 16, left: 16, bottom: 16, right: 16))
        yearStackView.autoMatch(.height, to: .height, of: rootStackView)

        avatarImageView.autoSetDimensions(to: .init(width: 55, height: 55))

        if let nickname = team.nickname {
            teamNumberLabel.text = team.fallbackNickname
            teamNameLabel.text = nickname
        } else {
            teamNumberLabel.text = team.fallbackNickname
            teamNameLabel.isHidden = true
        }

        // TODO: We *have* to fucking move this shit off the main thread
        if let year = year {
            if let avatar = team.avatar(year: year) {
                avatarImageView.isHidden = false
                avatarImageView.setAvatar(avatar)
            } else {
                avatarImageView.isHidden = true
            }
            setYearButtonTitle("\(year)")
        } else {
            avatarImageView.isHidden = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public Methods

    func setYearButtonTitle(_ title: String?) {
        yearButton.setTitle(title, for: .normal)
    }

    // MARK: Private Methods

    static func teamHeaderLabel() -> UILabel {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        return label
    }

}

private class AvatarImageView: UIView {

    private let imageView: UIImageView

    init(data: Data?) {
        let image: UIImage? = {
            if let data = data {
                return UIImage(data: data)
            }
            return nil
        }()
        imageView = UIImageView(image: image)
        imageView.backgroundColor = .clear

        super.init(frame: .zero)

        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: .init(top: 5, left: 5, bottom: 5, right: 5))

        layer.borderColor = UIColor.avatarBlue.cgColor
        layer.borderWidth = 5
        layer.masksToBounds = true
        layer.cornerRadius = 5

        backgroundColor = .avatarBlue

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(sender:)))
        addGestureRecognizer(tapGestureRecognizer)

        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public Methods

    // TODO: Probably needs loading methods

    func setAvatar(_ avatar: TeamMedia) {
        assert(avatar.type == MediaType.avatar.rawValue, "TeamMedia avatar must be an avatar")
        guard let base64Image = avatar.details?["base64Image"] as? String else {
            return
        }
        guard let avatarData = Data(base64Encoded: base64Image) else {
            return
        }
        imageView.image = UIImage(data: avatarData)
    }

    // MARK: Private Methods

    @objc func avatarTapped(sender: AnyObject) {
        let newColor = backgroundColor == .avatarBlue ? UIColor.avatarRed : UIColor.avatarBlue
        backgroundColor = newColor
        layer.borderColor = newColor.cgColor
    }

}

private class YearButton: UIButton {

    override open var isHighlighted: Bool {
        didSet {
            let mediumWhite = UIColor(white: 0.9, alpha: 1)
            UIView.animate(withDuration: 0.125) {
                self.backgroundColor = self.isHighlighted ? mediumWhite : UIColor.white
            }
        }
    }

    init() {
        super.init(frame: .zero)

        setTitle("---", for: .normal)
        setTitleColor(.primaryBlue, for: .normal)
        setImage(UIImage(named: "baseline_arrow_drop_down"), for: .normal)

        titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout, compatibleWith: nil).bold()

        tintColor = .primaryBlue
        backgroundColor = .white
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

        layer.masksToBounds = true
        setContentHuggingPriority(.defaultHigh, for: .horizontal)

        /*
        autoSetDimension(.width, toSize: 44, relation: .greaterThanOrEqual)
        autoSetDimension(.height, toSize: 24)
        */
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.size.height * 0.5
    }

}
