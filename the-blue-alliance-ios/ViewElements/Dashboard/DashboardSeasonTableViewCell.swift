import PureLayout
import UIKit

nonisolated struct DashboardSeasonViewModel: Hashable {
    /// The bold start of the sentence: a count of days, a week, or a milestone.
    let headline: String
    /// The rest of the sentence after the headline.
    let title: String
    let subtitle: String?
    /// 0...1 when the season has measurable progress, like the current week of the total.
    let progress: Double?
    let isTappable: Bool
}

/// The summary line at the top of the Dashboard: one sentence with its lead words in bold.
class DashboardSeasonTableViewCell: UITableViewCell, Reusable {

    var viewModel: DashboardSeasonViewModel? {
        didSet { configureCell() }
    }

    private let sentenceLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel(forAutoLayout: ())
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        return label
    }()

    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .highlightColor
        progressView.trackTintColor = .tertiarySystemFill
        return progressView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let stackView = UIStackView(arrangedSubviews: [sentenceLabel, subtitleLabel, progressView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.setCustomSpacing(10, after: subtitleLabel)

        contentView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewMargins(
            with: UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCell() {
        guard let viewModel else { return }

        let sentence = NSMutableAttributedString(
            string: viewModel.headline,
            attributes: [.font: Self.font(weight: .bold)]
        )
        sentence.append(
            NSAttributedString(
                string: " \(viewModel.title)",
                attributes: [.font: Self.font(weight: .regular)]
            )
        )
        sentenceLabel.attributedText = sentence

        subtitleLabel.text = viewModel.subtitle
        subtitleLabel.isHidden = viewModel.subtitle == nil

        if let progress = viewModel.progress {
            progressView.isHidden = false
            progressView.progress = Float(progress)
        } else {
            progressView.isHidden = true
        }

        accessoryType = viewModel.isTappable ? .disclosureIndicator : .none
        selectionStyle = viewModel.isTappable ? .default : .none
    }

    private static func font(weight: UIFont.Weight) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: .title3)
        return UIFontMetrics(forTextStyle: .title3).scaledFont(
            for: .systemFont(ofSize: base.pointSize, weight: weight)
        )
    }

}
