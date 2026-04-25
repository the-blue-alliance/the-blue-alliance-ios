import UIKit

final class AllianceBadgeView: UIView {

    enum Side {
        case red
        case blue

        var background: UIColor {
            switch self {
            case .red: return UIColor.redAllianceBackgroundColor
            case .blue: return UIColor.blueAllianceBackgroundColor
            }
        }
    }

    private let label = UILabel()
    private let pill = UIView()

    init(number: Int, name: String?, side: Side) {
        super.init(frame: .zero)
        setupViews()
        configure(number: number, name: name, side: side)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        isAccessibilityElement = true

        label.font = .boldSystemFont(ofSize: 11)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false

        pill.layer.cornerRadius = 6
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(label)

        addSubview(pill)
        NSLayoutConstraint.activate([
            pill.topAnchor.constraint(equalTo: topAnchor),
            pill.bottomAnchor.constraint(equalTo: bottomAnchor),
            pill.leadingAnchor.constraint(equalTo: leadingAnchor),
            pill.trailingAnchor.constraint(equalTo: trailingAnchor),

            label.topAnchor.constraint(equalTo: pill.topAnchor, constant: 2),
            label.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -2),
            label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -5),
        ])
    }

    func configure(number: Int, name: String?, side: Side) {
        pill.backgroundColor = side.background
        label.text = "A\(number)"
        if let name, !name.isEmpty {
            accessibilityLabel = name
        } else {
            accessibilityLabel = "Alliance \(number)"
        }
    }
}
