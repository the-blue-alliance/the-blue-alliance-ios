import UIKit

class InfoTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "InfoCell"
    var event: Event? {
        didSet {
            configureCell()
        }
    }
    var team: Team? {
        didSet {
            configureCell()
        }
    }
    @IBOutlet private var infoStackView: UIStackView!

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
        for view in infoStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        if let event = event {
            if let name = event.name {
                let nameLabel = titleLabelWithText(name)
                infoStackView.addArrangedSubview(nameLabel)
            }
            if let location = event.locationString {
                let locationLabel = subtitleLabelWithText(location)
                infoStackView.addArrangedSubview(locationLabel)
            }
            if let date = event.dateString() {
                let dateLabel = subtitleLabelWithText(date)
                infoStackView.addArrangedSubview(dateLabel)
            }
        } else if let team = team {
            let nicknameLabel = titleLabelWithText(team.nickname ?? team.fallbackNickname)
            infoStackView.addArrangedSubview(nicknameLabel)

            if let location = team.locationString {
                let locationLabel = subtitleLabelWithText(location)
                infoStackView.addArrangedSubview(locationLabel)
            }
            if let motto = team.motto {
                let mottoLabel = subtitleLabelWithText(motto)
                infoStackView.addArrangedSubview(mottoLabel)
            }
        }
    }
    
}
