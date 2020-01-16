import CoreGraphics
import Foundation
import SpriteKit
import TBAData
import UIKit

// TODO: Constants for FRC Field Size
private let colors = [
    "red": [UIColor.zebraRed1, UIColor.zebraRed2, UIColor.zebraRed3],
    "blue": [UIColor.zebraBlue1, UIColor.zebraBlue2, UIColor.zebraBlue3]
]

// TODO: We should probably just make this a view controller yeah?
class MatchZebraView: UIView {

    private var playing: Bool = false

    private lazy var fieldView: SKView = {
        let view = SKView()
        view.showsFPS = true
        view.showsNodeCount = true
        view.presentScene(fieldScene)
        return view
    }()
    private lazy var fieldScene = FieldScene(size: CGSize(width: 54, height: 27))

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fieldView, controlsStackView])
        stackView.axis = .vertical

        // Make sure we're always 27x54 aspect ratito
        fieldView.autoMatch(.height, to: .width, of: fieldView, withMultiplier: 0.5)

        return stackView
    }()
    var robotNodes: [String: SKNode] = [:]

    private var pathsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.addTarget(self, action: #selector(showInitialPaths), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    private var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        button.tintColor = UIColor.tabBarTintColor
        return button
    }()
    private var restartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.end.alt.fill"), for: .normal)
        button.tintColor = UIColor.tabBarTintColor
        return button
    }()
    private var slowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = UIColor.tabBarTintColor
        button.isEnabled = false
        return button
    }()
    private var speedLabel: UILabel = {
        let label = UILabel()
        label.text = "1x"
        return label
    }()
    private var fastButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = UIColor.tabBarTintColor
        return button
    }()
    private var timeLabel: UILabel = {
        var label = UILabel()
        label.text = "0:00"
        return label
    }()
    private lazy var controlsStackView: UIStackView = {
        let slider = UISlider()
        slider.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stackView = UIStackView(arrangedSubviews: [pathsButton, playButton, restartButton, slowButton, speedLabel, fastButton, slider, timeLabel])
        stackView.spacing = 8
        stackView.axis = .horizontal
        return stackView
    }()

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func redrawZebra(_ zebra: MatchZebra) {
        fieldScene.redrawZebra(zebra)
    }

    // MARK: - Interface Methods

    @objc private func showInitialPaths(_ zebra: MatchZebra) {
    }

    @objc private func togglePlayPause() {
        if playing {
            pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        playing = !playing
    }

    private func play() {

    }

    private func pause() {

    }

}

private class FieldScene: SKScene {

    private let zebra: MatchZebra

    private let background = SKSpriteNode(imageNamed: "2019_field")
    private var robots: [SKNode] = []
    private var paths: [SKNode] = []

    init(_ zebra: MatchZebra) {
        self.zebra = zebra

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()

        scaleMode = .resizeFill
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        background.zPosition = -1
        background.size = size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)

        addChild(background)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        // Background should always match frame size
        background.size = size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        redrawZebra(zebra)
    }

    func redrawZebra(_ zebra: MatchZebra) {
        removeChildren(in: robots)
        robots.removeAll()

        removeChildren(in: paths)
        paths.removeAll()

        // Draw everything based on a 27x54 ratio
        let scale = size.width / 54.0

        // TODO: Alternative here is to draw all robots and show random colors
        for alliance in zebra.alliances.filter({ colors.keys.contains($0.allianceKey) }) {
            let allianceColors = colors[alliance.allianceKey]!
            for (index, team) in alliance.teams.prefix(colors.count).enumerated() {
                let color = allianceColors[index]
                // Draw robot
                let robot = RobotNode(team: team.team, color: color)
                robot.position = team.firstPosition ?? CGPoint(x: 0, y: 0)
                addChild(robot)
                robots.append(robot)
                // Draw path
                let path = PathNode(team: team, color: color)
                addChild(path)
                paths.append(path)
            }
        }
    }

}

private class RobotNode: SKShapeNode {

    private let robotRadius: CGFloat = 1.3

    init(team: Team, color: UIColor, scale: CGFloat) {
        super.init(circleOfRadius: robotRadius * scale)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private class PathNode: SKShapeNode {

    init(team: MatchZebraTeam, color: UIColor) {
        super.init()

        let path = CGMutablePath()
        path.addLines(between: zip(team.xs, team.ys).compactMap {
            guard let x = $0, let y = $1 else {
                return nil
            }
            return CGPoint(x: x, y: y)
        })
        self.path = path
        strokeColor = color
        lineWidth = 0.1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
