import Foundation
import UIKit

protocol ScrollReporterDelegate: AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

// ScrollReporter describes a class that reports it's scrolling delegate methods calls upwards
protocol ScrollReporter: UIScrollViewDelegate {
    var scrollReporterDelegate: ScrollReporterDelegate? { get set }

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}
