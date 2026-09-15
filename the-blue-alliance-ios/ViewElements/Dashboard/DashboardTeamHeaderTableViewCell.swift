import PureLayout
import UIKit

struct DashboardTeamHeaderViewModel {
    let teamNumber: Int
    let nickname: String
    let eventName: String
    let eventDetail: String?
    let avatar: UIImage?
}

class DashboardTeamHeaderTableViewCell: UITableViewCell, Reusable {

    private static let avatarSize: CGFloat = 44

    var viewModel: DashboardTeamHeaderViewModel? {
        didSet { configureCell() }
    }

    private let avatarView: UIView = {
        let view = UIView(forAutoLayout: ())
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let numberLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        let base = UIFont.preferredFont(forTextStyle: .title3)
        label.font = UIFontMetrics(forTextStyle: .title3).scaledFont(
            for: .systemFont(ofSize: base.pointSize, weight: .bold)
        )
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()

    private let eventLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        return label
    }()

    private let eventDetailLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator

        avatarView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(
            with: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        )
        avatarView.autoSetDimensions(to: CGSize(width: Self.avatarSize, height: Self.avatarSize))

        let titleStack = UIStackView(arrangedSubviews: [numberLabel, nicknameLabel])
        titleStack.axis = .horizontal
        titleStack.alignment = .firstBaseline
        titleStack.spacing = 6

        let textStack = UIStackView(arrangedSubviews: [titleStack, eventLabel, eventDetailLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let rootStack = UIStackView(arrangedSubviews: [avatarView, textStack])
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.axis = .horizontal
        rootStack.alignment = .center
        rootStack.spacing = 12

        contentView.addSubview(rootStack)
        rootStack.autoPinEdgesToSuperviewMargins()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCell() {
        guard let viewModel else { return }
        numberLabel.text = String(viewModel.teamNumber)
        nicknameLabel.text = viewModel.nickname
        eventLabel.text = viewModel.eventName
        eventDetailLabel.text = viewModel.eventDetail
        eventDetailLabel.isHidden = viewModel.eventDetail == nil

        let base = UIColor.avatarBaseColor(teamNumber: viewModel.teamNumber)
        avatarView.backgroundColor = base
        avatarImageView.image = viewModel.avatar
        // No avatar: show the team number on the colored tile instead of an empty square.
        avatarImageView.isHidden = viewModel.avatar == nil
        placeholderLabel.text = viewModel.avatar == nil ? String(viewModel.teamNumber) : nil
    }

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        avatarView.addSubview(label)
        label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
        return label
    }()

}
