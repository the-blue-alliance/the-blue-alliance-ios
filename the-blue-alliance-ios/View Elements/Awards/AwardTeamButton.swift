import Foundation
import UIKit

class AwardTeamButton: UIView {

    private var widthConstraint: NSLayoutConstraint!
    var widthRange: ClosedRange<CGFloat>
    var headerText: String? {
        get { return headerLabel.text }
        set { headerLabel.text = newValue }
    }
    var subheaderText: String? {
        get { return subheaderLabel.text }
        set { subheaderLabel.text = newValue }
    }
    private let headerLabel = UILabel()
    private let subheaderLabel = UILabel()

    private var leftPadding: CGFloat = 10
    private var rightPadding: CGFloat = 40

    // Mark: - Init

    required init?(coder aDecoder: NSCoder) { fatalError() }

    init(header: String, subheader: String, widthRange: ClosedRange<CGFloat> = 0.3...0.65) {
        self.widthRange = widthRange
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false

        self.headerText = header
        self.subheaderText = subheader
        
        headerLabel.font = .systemFont(ofSize: 14, weight: .medium)
        headerLabel.textColor = .primaryBlue
        headerLabel.numberOfLines = 1
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subheaderLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium).italicized
        subheaderLabel.textColor = .black
        subheaderLabel.numberOfLines = 1
        subheaderLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPadding).isActive = true
        //headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -rightPadding).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        subheaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPadding).isActive = true
        //subheaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -rightPadding).isActive = true
        subheaderLabel.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        self.heightAnchor.constraint(equalTo: headerLabel.heightAnchor, multiplier: 2.5).isActive = true
        
        self.widthConstraint = widthAnchor.constraint(equalToConstant: self.widthRange.upperBound)
        widthConstraint.isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let superviewWidth = self.superview?.bounds.width else { return }
        let naturalWidth = max(headerLabel.intrinsicContentSize.width, subheaderLabel.intrinsicContentSize.width) + leftPadding + rightPadding
        let lower = widthRange.lowerBound * superviewWidth
        let upper = widthRange.upperBound * superviewWidth
        if naturalWidth > upper {
            widthConstraint.constant = upper
        }
        else if naturalWidth < lower {
            widthConstraint.constant = lower
        }
        else {
            widthConstraint.constant = naturalWidth
        }
    }

}
