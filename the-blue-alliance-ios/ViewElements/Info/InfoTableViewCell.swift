import UIKit

class InfoTableViewCell: UITableViewCell, Reusable {

    var viewModel: InfoCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var infoStackView: UIStackView!

    // MARK: - Private Methods

    private func removeInfo() {
        for view in infoStackView.arrangedSubviews {
            infoStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

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
        label.textColor = UIColor.secondaryLabel
        return label
    }

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        removeInfo()

        let nameLabel = titleLabelWithText(viewModel.nameString)
        infoStackView.addArrangedSubview(nameLabel)

        for subtitleString in viewModel.subtitleStrings {
            let subtitleLabel = subtitleLabelWithText(subtitleString)
            infoStackView.addArrangedSubview(subtitleLabel)
        }
    }

}
