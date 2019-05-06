import Foundation
import UIKit

class AwardTeamButton: UIView {

    var widthRange: ClosedRange<CGFloat> {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    var headerText: String? {
        get { return headerLabel.text }
        set {
            headerLabel.text = newValue
            invalidateIntrinsicContentSize()
        }
    }
    var subheaderText: String? {
        get { return subheaderLabel.text }
        set {
            subheaderLabel.text = newValue
            invalidateIntrinsicContentSize()
        }
    }
    private let headerLabel = UILabel()
    private let subheaderLabel = UILabel()
    private var arrowView = UIImageView(image: UIImage(named: "ic_arrow")?.withRenderingMode(.alwaysTemplate))

    private var leftPadding: CGFloat = 10
    private var rightPadding: CGFloat = 40

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: calculatedWidth, height: calculatedHeight)
        }
    }
    var calculatedWidth: CGFloat {
        let naturalWidth = max(headerLabel.intrinsicContentSize.width, subheaderLabel.intrinsicContentSize.width) + leftPadding + rightPadding
        guard let superviewWidth = self.superview?.bounds.width else { return naturalWidth }
        let lower = widthRange.lowerBound * superviewWidth
        let upper = widthRange.upperBound * superviewWidth
        if naturalWidth > upper { return upper }
        else if naturalWidth < lower {return lower }
        return naturalWidth
    }
    var calculatedHeight: CGFloat {
        return (headerLabel.intrinsicContentSize.height + subheaderLabel.intrinsicContentSize.height) * 1.5
    }

    // Mark: - Init

    required init?(coder aDecoder: NSCoder) { fatalError() }

    init(header: String, subheader: String, widthRange: ClosedRange<CGFloat> = 0.3...0.45) {
        self.widthRange = widthRange
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)

        self.headerText = header
        self.subheaderText = subheader

        arrowView.tintColor = UIColor.colorWithRGB(rgbValue: 0xBEBEBE)
        arrowView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        arrowView.translatesAutoresizingMaskIntoConstraints = false

        headerLabel.font = .systemFont(ofSize: 14, weight: .medium)
        headerLabel.textColor = .primaryBlue
        headerLabel.numberOfLines = 1
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        subheaderLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium).italicized
        subheaderLabel.textColor = .black
        subheaderLabel.numberOfLines = 1
        subheaderLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(arrowView)
        self.addSubview(headerLabel)
        self.addSubview(subheaderLabel)

        // define constraints
        defineConstraints()

        // border
        self.layer.borderColor = UIColor.colorWithRGB(rgbValue: 0xBEBEBE).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
    }

    convenience init() {
        self.init(header: "", subheader: "")
    }

    // Mark: - Methods
    private func defineConstraints() {
        arrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        arrowView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        arrowView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true

        headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPadding).isActive = true
        headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -rightPadding).withPriority(.defaultHigh).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        headerLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        headerLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        subheaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPadding).isActive = true
        subheaderLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -rightPadding).withPriority(.defaultHigh).isActive = true
        subheaderLabel.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        subheaderLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        subheaderLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    // Mark: View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

}
