import Foundation
import UIKit

// pattern from http://alisoftware.github.io/swift/generics/2016/01/06/generic-tableviewcells/

protocol Reusable {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension Reusable {
    static var reuseIdentifier: String { String(describing: Self.self) }
    static var nib: UINib? { nil }
}

extension UITableView {
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: Reusable {
        dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T? where T: Reusable {
        dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T?
    }
}

extension UICollectionView {
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: Reusable {
        dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func registerReusableSupplementaryView<T: Reusable & AnyObject>(elementKind: String, _: T.Type) {
        if let nib = T.nib {
            register(nib, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseIdentifier)
        } else {
            register(T.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(elementKind: String, indexPath: IndexPath) -> T where T: Reusable {
        dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
