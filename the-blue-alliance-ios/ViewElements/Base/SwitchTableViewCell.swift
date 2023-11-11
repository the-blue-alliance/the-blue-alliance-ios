import Foundation
import UIKit

class SwitchTableViewCell: UITableViewCell {

    private var switchToggled: ((_: UISwitch) -> ())

    // MARK: - Init

    init(switchToggled: @escaping ((_: UISwitch) -> ())) {
        self.switchToggled = switchToggled

        super.init(style: .subtitle, reuseIdentifier: nil)

        accessoryView = switchView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    public lazy var switchView: UISwitch! = {
        let switchView = UISwitch(frame: .zero)
        switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        return switchView
    }()

    @objc func switchValueChanged(_ sender: UISwitch) {
        self.switchToggled(sender)
    }

}
