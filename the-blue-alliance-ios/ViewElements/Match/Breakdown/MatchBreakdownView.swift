import Foundation
import UIKit

class BreakdownStyle {

    public static let filledCheckImage = UIImage(systemName: "checkmark.circle.fill")
    public static let checkImage = UIImage(systemName: "checkmark")
    public static let xImage = UIImage(systemName: "xmark")

    static public func breakdownLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.label
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }

    static public func imageView(image: UIImage?, tintColor: UIColor = UIColor.label, contentMode: UIView.ContentMode = UIView.ContentMode.scaleToFill, forceSquare: Bool = true) -> UIImageView {
        let imageView = UIImageView(image: image)
        if forceSquare {
            imageView.autoMatch(.width, to: .height, of: imageView)
        }
        imageView.contentMode = contentMode
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
        imageView.tintColor = tintColor
        return imageView
    }

}

protocol BreakdownElement: Any {
    func toView() -> UIView
}

extension String: BreakdownElement {
    func toView() -> UIView {
        let label = BreakdownStyle.breakdownLabel()
        label.text = self
        return label
    }
}

extension UIStackView: BreakdownElement {
    func toView() -> UIView {
        return self
    }
}

extension UIImage: BreakdownElement {
    func toView() -> UIView {
        let imageView = UIImageView(image: self)
        imageView.tintColor = UIColor.label
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
        return imageView
    }
}

extension UIImageView: BreakdownElement {
    func toView() -> UIView {
        return self
    }
}

class MatchBreakdownTableViewCell: UITableViewCell, Reusable {

    private let defaultFont = UIFont.preferredFont(forTextStyle: .subheadline)

    var titleText: String? {
        didSet {
            breakdownView.titleLabel.text = titleText
        }
    }
    var redElements: [BreakdownElement] = [] {
        didSet {
            breakdownView.redStackView.arrangedSubviews.forEach {
                breakdownView.redStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            redElements.forEach {
                breakdownView.redStackView.addArrangedSubview($0.toView())
            }
        }
    }
    var blueElements: [BreakdownElement] = [] {
        didSet {
            breakdownView.blueStackView.arrangedSubviews.forEach {
                breakdownView.redStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            blueElements.forEach {
                breakdownView.blueStackView.addArrangedSubview($0.toView())
            }
        }
    }
    var type: BreakdownRow.BreakdownRowType = .normal {
        didSet {
            breakdownView.type = type
            updateCell()
        }
    }
    lazy var breakdownView = MatchBreakdownView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(breakdownView)
        breakdownView.autoPinEdgesToSuperviewEdges()
        breakdownView.autoSetDimension(.height, toSize: 44, relation: .greaterThanOrEqual)

        separatorInset = .zero
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateCell() {
        let font: UIFont = {
            switch type {
            case .total:
                return defaultFont.bold()
            default:
                return defaultFont
            }
        }()
        [breakdownView.redStackView.arrangedSubviews, breakdownView.blueStackView.arrangedSubviews].forEach {
            $0.compactMap({ $0 as? UILabel }).forEach({ $0.font = font })
        }
    }

}

class MatchBreakdownView: UIView {

    private let defaultFont = UIFont.preferredFont(forTextStyle: .subheadline)

    var type: BreakdownRow.BreakdownRowType = .normal {
        didSet {
            titleLabel.font = defaultFont

            switch type {
            case .total:
                // Configure title label
                titleLabel.font = defaultFont.bold()
                fallthrough
            case .subtotal:
                // Configure title view
                titleView.backgroundColor = .systemGray5
                // Configure red view
                redView.backgroundColor = UIColor.redAllianceScoreBackgroundColor
                // Configure blue view
                blueView.backgroundColor = UIColor.blueAllianceScoreBackgroundColor
            default:
                // Configure title view
                titleView.backgroundColor = .systemGray6
                // Configure red view
                redView.backgroundColor = UIColor.redAllianceBackgroundColor
                // Configure blue view
                blueView.backgroundColor = UIColor.blueAllianceBackgroundColor
            }
        }
    }

    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6

        view.addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: .init(top: 8, left: 8, bottom: 8, right: 8))

        return view
    }()
    fileprivate lazy var titleLabel = BreakdownStyle.breakdownLabel()

    lazy var redView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.redAllianceBackgroundColor

        view.addSubview(redInternalStackView)
        redInternalStackView.autoPinEdgesToSuperviewSafeArea(with: .init(top: 8, left: 8, bottom: 8, right: 8))

        return view
    }()
    lazy var redStackView = UIStackView()
    private lazy var redInternalStackView = internalStackView(redStackView)

    lazy var blueView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blueAllianceBackgroundColor

        view.addSubview(blueInternalStackView)
        blueInternalStackView.autoPinEdgesToSuperviewSafeArea(with: .init(top: 8, left: 8, bottom: 8, right: 8))

        return view
    }()
    lazy var blueStackView = UIStackView()
    private lazy var blueInternalStackView = internalStackView(blueStackView)

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [redView, titleView, blueView])
        stackView.axis = .horizontal
        return stackView
    }()

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()

        // redView and blueView should make up 20/20 of the total size, title should be 60
        redView.autoMatch(.width, to: .width, of: self, withMultiplier: 0.25) // Web is 1/6
        blueView.autoMatch(.width, to: .width, of: redView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    func internalStackView(_ sv: UIStackView) -> UIStackView {
        let spacerLeft = UIView()
        let spacerRight = UIView()

        let stackView = UIStackView(arrangedSubviews: [spacerLeft, sv, spacerRight])
        stackView.alignment = .center

        spacerLeft.autoSetDimension(.width, toSize: 0, relation: .greaterThanOrEqual)
        spacerRight.autoSetDimension(.width, toSize: 0, relation: .greaterThanOrEqual)
        spacerLeft.autoMatch(.width, to: .width, of: spacerRight)

        return stackView
    }

}
