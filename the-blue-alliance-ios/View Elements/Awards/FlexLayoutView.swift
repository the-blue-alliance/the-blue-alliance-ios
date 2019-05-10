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
    var specifiedWidth: CGFloat?
    override var intrinsicContentSize: CGSize {
        return CGSize(width: specifiedWidth ?? UIScreen.main.bounds.width, height: self.calculatedHeight)
    }
    var calculatedHeight: CGFloat = 0

    // Mark: - Init

    required init?(coder aDecoder: NSCoder) { fatalError() }

    init(width: CGFloat? = nil) {
        super.init(frame: .zero)
        self.specifiedWidth = width
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setContentHuggingPriority(.defaultHigh, for: .vertical)
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
        var counter = 1
        for view in views {
            if currentX + horizontalSpacing + view.intrinsicContentSize.width > self.intrinsicContentSize.width {
                currentX = 0
                currentRow += 1
                currentRowY = rowMaxY + verticalSpacing
                rowMaxY = currentRowY
                counter += 1
            }
            view.frame = CGRect(x: currentX, y: currentRowY, width: view.bounds.width, height: view.bounds.height)
            if view.bounds.height + currentRowY > rowMaxY { rowMaxY = view.bounds.height + currentRowY }
            currentX += horizontalSpacing + view.intrinsicContentSize.width
        }

        self.calculatedHeight = rowMaxY
        self.invalidateIntrinsicContentSize()
    }

}
