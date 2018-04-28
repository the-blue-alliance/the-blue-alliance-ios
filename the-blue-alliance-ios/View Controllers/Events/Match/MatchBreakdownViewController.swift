//
//  MatchBreakdownViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/22/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import React
import TBAKit
import CoreData

class MatchBreakdownViewController: TBAViewController, Observable, ReactNative {
    
    public var match: Match!
    
    // MARK: - React Native
    
    lazy internal var reactBridge: RCTBridge = {
        return RCTBridge(delegate: self, launchOptions: [:])
    }()
    private var breakdownView: RCTRootView?
    
    // MARK: - Persistable
    
    override var persistentContainer: NSPersistentContainer! {
        didSet {
            contextObserver.observeObject(object: match, state: .updated) { [weak self] (_, _) in
                DispatchQueue.main.async {
                    self?.updateBreakdownView()
                }
            }
        }
    }
    
    // MARK: - Observable
    
    typealias ManagedType = Match
    lazy var contextObserver: CoreDataContextObserver<Match> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Move this... out. Somewhere else. In the ReactNative Protocol
        NotificationCenter.default.addObserver(self, selector: #selector(showErrorView), name: NSNotification.Name.RCTJavaScriptDidFailToLoad, object: nil)
        
        styleInterface()
    }
    
    // MARK: Interface Methods
    
    func styleInterface() {
        view.backgroundColor = UIColor.colorWithRGB(rgbValue: 0xdddddd)
        updateBreakdownView()
    }
    
    func updateBreakdownView() {
        // Match breakdowns only exist for 2015 and onward
        if Int(match.event!.year) < 2015 {
            return
        }
        
        // If the breakdown view already exists, don't set it up again
        // Only update the properties for the view
        if let breakdownView = breakdownView {
            breakdownView.appProperties = dataForBreakdown()
            return
        }

        let initialProps = dataForBreakdown()
        let moduleName = "MatchBreakdown\(match.event!.year)"

        guard let breakdownView = RCTRootView(bridge: reactBridge, moduleName: moduleName, initialProperties: initialProps) else {
            showErrorView()
            return
        }
        
        // breakdownView.loadingView
        breakdownView.delegate = self
        breakdownView.sizeFlexibility = .height
        
        removeNoDataView()
        scrollView.addSubview(breakdownView)
        
        breakdownView.autoMatch(.width, to: .width, of: scrollView)
        breakdownView.autoPinEdgesToSuperviewEdges()
    }
    
    // MARK: Private
    
    func dataForBreakdown() -> [String: Any] {
        let redAllianceTeams = match.redAlliance?.array as? [Team]
        let redAlliance = redAllianceTeams?.map({ (team) -> String in
            return "\(team.teamNumber)"
        })
        
        let blueAllianceTeams = match.blueAlliance?.array as? [Team]
        let blueAlliance = blueAllianceTeams?.map({ (team) -> String in
            return "\(team.teamNumber)"
        })
        
        return ["redTeams" : redAlliance ?? [],
                "redBreakdown": match.redBreakdown ?? [:],
                "blueTeams": blueAlliance ?? [],
                "blueBreakdown": match.blueBreakdown ?? [:],
                "compLevel": match.compLevel!]
    }
    
    // MARK: - RCTBridgeDelegate
    
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        // Fetch our downloaded JS bundle (or our loctaal packager, if we're running in debug mode)
        return sourceURL
    }
    // fallbackSourceURL
    
    // MARK: Refresh
    
    override func shouldNoDataRefresh() -> Bool {
        return match.redBreakdown == nil || match.blueBreakdown == nil
    }
    
    override func refresh() {
        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchMatch(key: match.key!, { (modelMatch, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh match breakdown - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.match.event!.objectID) as! Event
                
                if let modelMatch = modelMatch {
                    backgroundEvent.addToMatches(Match.insert(with: modelMatch, for: backgroundEvent, in: backgroundContext))
                }
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh match breakdown - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }
    
    override func optionallyShowNoDataView() {
        if shouldNoDataRefresh() {
            showNoDataView(with: "No breakdown for match")
        } else {
            updateBreakdownView()
        }
    }
    
    // MARK: Notifications
    
    @objc func showErrorView() {
        // TODO: Think about logging an error here or something so we know if match brekadown fails, since we can fix
        showNoDataView(with: "Unable to load match breakdown")
    }
    
}

extension MatchBreakdownViewController: RCTRootViewDelegate {

    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        rootView.autoSetDimension(.height, toSize: rootView.intrinsicContentSize.height)
    }

}
