import Foundation
import UIKit

/**
 Simple Flex Layout (like CSS) where items populate by row (each item can have it's own width and length. New rows are automatically added.
 Only meant for small grid layouts.
 */
class FlexLayoutView: UIView {

    private(set) var views: [UIView] = []
    var verticalSpacing: CGFloat = 0
    var horizontalSpacing: CGFloat = 0
    private var heightConstraint: NSLayoutConstraint!

    // Mark: - Init

    required init?(coder aDecoder: NSCoder) { fatalError() }

    init() {
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
    }

    // Mark: Methods

    func addView(view: UIView) {
        self.addSubview(view)
        self.views.append(view)
    }
    
    func removeView(view: UIView) {
        if let index = views.index(of: view) {
            self.views.remove(at: index)
        }
    }
    
    func removeAllViews() {
        for view in views {
            view.removeFromSuperview()
        }
        self.views.removeAll()
    }

    // Mark: View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        var currentRow = 0
        var currentX: CGFloat = 0
        var rowMaxY: CGFloat = 0
        var currentRowY: CGFloat = 0
        for view in views {
            if currentX + horizontalSpacing + view.bounds.width > self.bounds.width {
                currentX = 0
                currentRow += 1
                currentRowY = rowMaxY + verticalSpacing
                rowMaxY = currentRowY
            }
            view.frame = CGRect(x: currentX, y: currentRowY, width: view.bounds.width, height: view.bounds.height)
            if view.bounds.height + currentRowY > rowMaxY { rowMaxY = view.bounds.height + currentRowY }
            currentX += horizontalSpacing + view.bounds.width
        }
        heightConstraint.constant = rowMaxY
    }

}
