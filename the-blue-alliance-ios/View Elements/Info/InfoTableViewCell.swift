import UIKit

class InfoTableViewCell: UITableViewCell {
    static let reuseIdentifier = "InfoCell"

    var viewModel: InfoCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var infoStackView: UIStackView!

    // MARK: - View Methods

    override func prepareForReuse() {
        super.prepareForReuse()

        for view in infoStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

    // MARK: - Private Methods

    private func labelWithText(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        return label
    }

    private func titleLabelWithText(_ text: String) -> UILabel {
        let label = labelWithText(text)
        label.font = .systemFont(ofSize: 18)
        return label
    }

    private func subtitleLabelWithText(_ text: String) -> UILabel {
        let label = labelWithText(text)
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        let nameLabel = titleLabelWithText(viewModel.nameString)
        infoStackView.addArrangedSubview(nameLabel)

        for subtitleString in viewModel.subtitleStrings {
            let subtitleLabel = subtitleLabelWithText(subtitleString)
            infoStackView.addArrangedSubview(subtitleLabel)
        }
    }

}
