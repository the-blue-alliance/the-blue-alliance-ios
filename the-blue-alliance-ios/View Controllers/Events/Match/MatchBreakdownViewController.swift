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

class MatchBreakdownViewController: TBAViewController, Observable {
    
    public var match: Match!
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
        if let _ = breakdownView {
            breakdownView?.appProperties = dataForBreakdown()
            return
        }

        guard let jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil) else {
            self.showNoDataView(with: "Unable to load breakdown")
            return
        }

        let initialProps = dataForBreakdown()
        
        let moduleName = "MatchBreakdown\(match.event!.year)"
        
        guard let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: moduleName, initialProperties: initialProps, launchOptions: [:]) else {
            self.showNoDataView(with: "Unable to load breakdown")
            return
        }
        breakdownView = rootView
        breakdownView!.delegate = self
        breakdownView!.sizeFlexibility = .height
        
        scrollView.addSubview(breakdownView!)
        breakdownView!.autoMatch(.width, to: .width, of: scrollView)
        breakdownView!.autoPinEdgesToSuperviewEdges()
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
    
    // MARK: Refresh
    
    override func shouldNoDataRefresh() -> Bool {
        return match.redBreakdown == nil || match.blueBreakdown == nil
    }
    
    override func refresh() {
        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchMatch(key: match.key!, { (modelMatch, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh match - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.match.event!.objectID) as! Event
                
                if let modelMatch = modelMatch {
                    backgroundEvent.addToMatches(Match.insert(with: modelMatch, for: backgroundEvent, in: backgroundContext))
                }
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh match - database error")
                }
                
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }
    
}

extension MatchBreakdownViewController: RCTRootViewDelegate {

    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        rootView.autoSetDimension(.height, toSize: rootView.intrinsicContentSize.height)
    }

}
