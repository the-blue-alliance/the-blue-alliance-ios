import TBAData
import SwiftUI

struct RobotLabel: View {

    private let colors = [
        "red": [Color.zebraRed1, Color.zebraRed2, Color.zebraRed3],
        "blue": [Color.zebraBlue1, Color.zebraBlue2, Color.zebraBlue3]
    ]

    let team: MatchZebraTeam
    let index: Int

    /*
    var color: Color {
        let colors = self.colors[alliance.allianceKey] ?? self.colors["red"]
        guard let teamIndex = alliance.teams.firstIndex(of: team) else {
            return .random
        }
        return colors?[teamIndex] ?? .random
    }
    */

    var body: some View {
        VStack {
            Image(systemName: "\(index + 1).circle")
                .scaledToFit()
            Text(String(team.team.teamNumber))
        }
        .foregroundColor(.white)
    }

}

struct Robot: View {

    let team: MatchZebraTeam
    let index: Int
    let color: Color

    // TODO: If we're on a phone, show the digits/table
    // If we're on an iPad, show the numbers

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Circle()
                    .foregroundColor(self.color)
                Image(systemName: "\(self.index + 1).circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(.white)
            }
        }
    }

}

struct FieldSize {
    static let width: CGFloat = 54.0
    static let height: CGFloat = 27.0
}

struct RobotSize {
    static let radius: CGFloat = 1.3
    static let stroke: CGFloat =  0.2

    static var strokePercentage: CGFloat {
        return stroke / (stroke + radius)
    }
    static var total: CGFloat {
        return (stroke + radius) * 2
    }
}

struct ZebraView: View {

    let teams: [MatchZebraTeam]
    let colors: [Color]

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.teams.count) { teamIndex in
                Robot(team: self.teams[teamIndex],
                      index: teamIndex,
                      color: self.colors[teamIndex])
                    .position(self.intervalPosition(team: self.teams[teamIndex],
                                                    geometry: geometry))
                    .frame(width: self.robotSize(geometry: geometry),
                           height: self.robotSize(geometry: geometry))
            }
        }
    }

    private func intervalPosition(team: MatchZebraTeam, geometry: GeometryProxy) -> CGPoint {
        guard let position = team.firstPosition else {
            return .zero
        }
        // Invert our Y - positions are from bottom-left, UIKit is from top-right
        let y = FieldSize.height - position.y
        let scale = geometry.size.width / FieldSize.width
        return CGPoint(x: position.x * scale, y: y * scale)
    }

    private func robotSize(geometry: GeometryProxy) -> CGFloat {
        // Robots should be a 1.3-radius circle with a 0.2 stroke
        let scale = geometry.size.width / FieldSize.width
        return scale * RobotSize.total
    }

}

struct MatchZebraView: View {

    private let colors = [
        Color.zebraRed1, Color.zebraRed2, Color.zebraRed3,
        Color.zebraBlue1, Color.zebraBlue2, Color.zebraBlue3
    ]

    @ObservedObject var match: Match

    @State var playing = false

    @State private var time: Double = 0

    @State private var interval: Int = 0
    private var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {_ in
            // self.interval = (self.interval + 1) % self.zebraData.times.count
        }
    }

    var body: some View {
        VStack {
            /*
            match.zebra.map {
                AllianceTable(teams: $0.teams,
                              colors: colors
                )
            }
            */
            ZStack {
                Image("2019_field")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                match.zebra.map {
                    ZebraView(
                        teams: $0.teams,
                        colors: colors
                    )
                    .clipped()
                }
            }
            HStack {
                Image(systemName: "eye.fill")
                Button(action: {

                }) {
                    playing ? Image(systemName: "play.fill") : Image(systemName: "pause.fill")
                }
                Image(systemName: "eye.fill")
                Image(systemName: "backward.end.alt.fill")
                Image(systemName: "backward.fill")
                Text("5x")
                Image(systemName: "forward.fill")
                // Slider(value: $time, in: 0.0...Double($0.times.count), step: 1.0)
                Text("0:00")
            }
        }
        .onAppear(perform: {
            _ = self.timer
        })
    }

}

struct AllianceTable: View {

    let teams: [MatchZebraTeam]
    let colors: [Color]

    var body: some View {
        HStack(alignment: .center) {
            ForEach(0..<teams.count, id: \.self) { (teamIndex: Int) in
                Group {
                    RobotLabel(team: self.teams[teamIndex], index: teamIndex)
                }
                .background(self.colors[teamIndex])
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
    }

}

//import CoreGraphics
//import Foundation
//import SpriteKit
//import TBAData
//import UIKit
//
//// TODO: Constants for FRC Field Size
//
//// TODO: We should probably just make this a view controller yeah?
//class MatchZebraView: UIView {
//
//    private var playing: Bool = false
//
//    private lazy var fieldView: SKView = {
//        let view = SKView()
//        view.showsFPS = true
//        view.showsNodeCount = true
//        view.presentScene(fieldScene)
//        return view
//    }()
//    private lazy var fieldScene = FieldScene(size: CGSize(width: 54, height: 27))
//
//    private lazy var stackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [fieldView, controlsStackView])
//        stackView.axis = .vertical
//
//        // Make sure we're always 27x54 aspect ratito
//        fieldView.autoMatch(.height, to: .width, of: fieldView, withMultiplier: 0.5)
//
//        return stackView
//    }()
//    var robotNodes: [String: SKNode] = [:]
//
//    private var pathsButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
//        button.addTarget(self, action: #selector(showInitialPaths), for: .touchUpInside)
//        button.isEnabled = false
//        return button
//    }()
//    private var playButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        button.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
//        button.tintColor = UIColor.tabBarTintColor
//        return button
//    }()
//    private var restartButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "backward.end.alt.fill"), for: .normal)
//        button.tintColor = UIColor.tabBarTintColor
//        return button
//    }()
//    private var slowButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
//        button.tintColor = UIColor.tabBarTintColor
//        button.isEnabled = false
//        return button
//    }()
//    private var speedLabel: UILabel = {
//        let label = UILabel()
//        label.text = "1x"
//        return label
//    }()
//    private var fastButton: UIButton = {
//        let button = UIButton()
//        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
//        button.tintColor = UIColor.tabBarTintColor
//        return button
//    }()
//    private var timeLabel: UILabel = {
//        var label = UILabel()
//        label.text = "0:00"
//        return label
//    }()
//    private lazy var controlsStackView: UIStackView = {
//        let slider = UISlider()
//        slider.setContentHuggingPriority(.defaultLow, for: .horizontal)
//
//        let stackView = UIStackView(arrangedSubviews: [pathsButton, playButton, restartButton, slowButton, speedLabel, fastButton, slider, timeLabel])
//        stackView.spacing = 8
//        stackView.axis = .horizontal
//        return stackView
//    }()
//
//    // MARK: - Init
//
//    init() {
//        super.init(frame: .zero)
//
//        addSubview(stackView)
//        stackView.autoPinEdgesToSuperviewEdges()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Public Methods
//
//    func redrawZebra(_ zebra: MatchZebra) {
//        fieldScene.redrawZebra(zebra)
//    }
//
//    // MARK: - Interface Methods
//
//    @objc private func showInitialPaths(_ zebra: MatchZebra) {
//    }
//
//    @objc private func togglePlayPause() {
//        if playing {
//            pause()
//            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        } else {
//            play()
//            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//        }
//        playing = !playing
//    }
//
//    private func play() {
//
//    }
//
//    private func pause() {
//
//    }
//
//}
//
//private class FieldScene: SKScene {
//
//    private let zebra: MatchZebra
//
//    private let background = SKSpriteNode(imageNamed: "2019_field")
//    private var robots: [SKNode] = []
//    private var paths: [SKNode] = []
//
//    init(_ zebra: MatchZebra) {
//        self.zebra = zebra
//
//        super.init()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func sceneDidLoad() {
//        super.sceneDidLoad()
//
//        scaleMode = .resizeFill
//    }
//
//    override func didMove(to view: SKView) {
//        super.didMove(to: view)
//
//        background.zPosition = -1
//        background.size = size
//        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
//
//        addChild(background)
//    }
//
//    override func didChangeSize(_ oldSize: CGSize) {
//        // Background should always match frame size
//        background.size = size
//        background.position = CGPoint(x: frame.midX, y: frame.midY)
//        redrawZebra(zebra)
//    }
//
//    func redrawZebra(_ zebra: MatchZebra) {
//        removeChildren(in: robots)
//        robots.removeAll()
//
//        removeChildren(in: paths)
//        paths.removeAll()
//
//        // Draw everything based on a 27x54 ratio
//        let scale = size.width / 54.0
//
//        // TODO: Alternative here is to draw all robots and show random colors
//        for alliance in zebra.alliances.filter({ colors.keys.contains($0.allianceKey) }) {
//            let allianceColors = colors[alliance.allianceKey]!
//            for (index, team) in alliance.teams.prefix(colors.count).enumerated() {
//                let color = allianceColors[index]
//                // Draw robot
//                let robot = RobotNode(team: team.team, color: color)
//                robot.position = team.firstPosition ?? CGPoint(x: 0, y: 0)
//                addChild(robot)
//                robots.append(robot)
//                // Draw path
//                let path = PathNode(team: team, color: color)
//                addChild(path)
//                paths.append(path)
//            }
//        }
//    }
//
//}
//
//private class RobotNode: SKShapeNode {
//
//    private let robotRadius: CGFloat = 1.3
//
//    init(team: Team, color: UIColor, scale: CGFloat) {
//        super.init(circleOfRadius: robotRadius * scale)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}
//
//private class PathNode: SKShapeNode {
//
//    init(team: MatchZebraTeam, color: UIColor) {
//        super.init()
//
//        let path = CGMutablePath()
//        path.addLines(between: zip(team.xs, team.ys).compactMap {
//            guard let x = $0, let y = $1 else {
//                return nil
//            }
//            return CGPoint(x: x, y: y)
//        })
//        self.path = path
//        strokeColor = color
//        lineWidth = 0.1
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}
