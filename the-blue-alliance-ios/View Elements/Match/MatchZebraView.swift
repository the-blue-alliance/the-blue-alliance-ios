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
    // pathTimeLength = 50
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

enum PlaybackSpeed: Int, CaseIterable {
    case one = 1
    case five = 5
    case ten = 10
}

struct ZebraView: View {

    let times: [Double]
    let teams: [MatchZebraTeam]
    let colors: [Color]
    let timestamp: Double

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.teams.count) { teamIndex in
                Robot(team: self.teams[teamIndex],
                      index: teamIndex,
                      color: self.colors[teamIndex])
                    .position(self.intervalPosition(times: self.times,
                                                    team: self.teams[teamIndex],
                                                    timestamp: self.timestamp,
                                                    geometry: geometry))
                    .animation(.linear)
                    .frame(width: self.robotSize(geometry: geometry),
                           height: self.robotSize(geometry: geometry))
            }
        }
    }

    // TODO: DRY this out like we do on Web
    private func intervalPosition(times: [Double], team: MatchZebraTeam, timestamp: Double, geometry: GeometryProxy) -> CGPoint {
        // TODO: Use `firstPosition` when we init
        /*
        guard let position = team.firstPosition else {
            return .zero
        }
        */
        // Get our interpolated position for our timestamp
        // Round our values up/down and to the nearest tenth
        let timestampFloor = floor(timestamp * 10.0) / 10.0
        let timestampCeiling = ceil(timestamp * 10.0) / 10.0

        // Find where our team is starting at and where our team is going to next in points
        guard let lastPositionIndex = times.firstIndex(of: timestampFloor),
            let lastPositionX = team.xs[lastPositionIndex],
            let lastPositionY = team.ys[lastPositionIndex] else {
                // TODO: Return whatever position we're currently in
                return .zero
        }
        guard let nextPositionIndex = times.firstIndex(of: timestampCeiling),
            let nextPositionX = team.xs[nextPositionIndex],
            let nextPositionY = team.ys[nextPositionIndex] else {
                // TODO: Return whatever position we're currently in
                return .zero
        }

        let slopeX = (nextPositionX - lastPositionX)
        let slopeY = (nextPositionY - lastPositionY)

        let deltaX = (timestamp - timestampFloor) * slopeX
        let deltaY = (timestamp - timestampFloor) * slopeY

        // return CGPoint(x: lastPositionX + deltaX, y: lastPositionY + deltaY)

        let x = CGFloat(lastPositionX + deltaX)
        let y = FieldSize.height - CGFloat(lastPositionY + deltaY)
        let scale = geometry.size.width / FieldSize.width
        return CGPoint(x: x * scale, y: y * scale)

        /*
        guard let position = team.firstPosition else {
            return .zero
        }
        // Invert our Y - positions are from bottom-left, UIKit is from top-right
        let y = FieldSize.height - position.y
        let scale = geometry.size.width / FieldSize.width
        return CGPoint(x: position.x * scale, y: y * scale)
        */
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
    @State var playbackSpeed = PlaybackSpeed.five

    @State private var timestamp: Double = 0.0
    private var timer: Timer {
        // 60fps
        Timer.scheduledTimer(withTimeInterval: (1.0/60.0), repeats: true) { timer in
            guard self.playing else {
                return
            }
            // TODO: Is `times` ordered?
            self.timestamp += timer.timeInterval
            // Round our timestamp to repeat when we hit our last timestamp - default to 2:30
            self.timestamp = self.timestamp.truncatingRemainder(dividingBy: self.match.zebra?.times.last ?? 150.0)
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
                        times: $0.times,
                        teams: $0.teams,
                        colors: colors,
                        timestamp: timestamp
                    )
                    .clipped()
                }
            }
            HStack {
                Image(systemName: "eye.fill")
                Button(action: {
                    self.playing = !self.playing
                }) {
                    playing ? Image(systemName: "pause.fill") : Image(systemName: "play.fill")
                }
                Button(action: {
                    // TODO: Disable if at start
                    self.timestamp = 0.0
                }) {
                    Image(systemName: "backward.end.alt.fill")
                }
                .disabled(timestamp == 0.0 && !playing)
                Button(action: {
                    self.playbackSpeed = PlaybackSpeed(rawValue: self.playbackSpeed.rawValue - 1) ?? PlaybackSpeed.allCases.first!
                }) {
                    Image(systemName: "backward.fill")
                }
                .disabled(playbackSpeed == PlaybackSpeed.allCases.first)
                Text("\(playbackSpeed.rawValue)x")
                Button(action: {
                    self.playbackSpeed = PlaybackSpeed(rawValue: self.playbackSpeed.rawValue + 1) ?? PlaybackSpeed.allCases.last!
                }) {
                    Image(systemName: "forward.fill")
                }
                .disabled(playbackSpeed == PlaybackSpeed.allCases.last)
                // Slider(value: $time, in: 0.0...Double($0.times.count), step: 1.0)
                Text("\(floor(timestamp / 60)):\(floor(timestamp.truncatingRemainder(dividingBy: 60)))")
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
