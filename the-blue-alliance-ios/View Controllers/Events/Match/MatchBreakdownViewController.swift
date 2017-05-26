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

class MatchBreakdownViewController: TBAViewController {
    
    public var match: Match!
    override var persistentContainer: NSPersistentContainer! {
        didSet {
            registerForChangeNotifications { (obj) in
                if obj == self.match {
                    DispatchQueue.main.async {
                        self.updateBreakdownView()
                    }
                }
            }
        }
    }
    private var breakdownView: RCTRootView?
    
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
        // TODO: Use year when creating moduleName
        guard let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: "TBAMatchBreakdown", initialProperties: initialProps, launchOptions: [:]) else {
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
        let redAlliance = match.redAlliance?.allObjects.map({ (team) -> String in
            return "\((team as! Team).teamNumber)"
        })
        let blueAlliance = match.blueAlliance?.allObjects.map({ (team) -> String in
            return "\((team as! Team).teamNumber)"
        })
        return ["redTeams" : redAlliance ?? [],
                "redBreakdown": match.redBreakdown ?? [:],
                "blueTeams": blueAlliance ?? [],
                "blueBreakdown": match.blueBreakdown ?? [:]]
    }
    
    // MARK: Refresh
    
    override func shouldNoDataRefresh() -> Bool {
        return match.redBreakdown == nil || match.blueBreakdown == nil
    }
    
    override func refresh() {
        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBAMatch.fetchMatch(key: match.key!, { (modelMatch, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh match - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.match.event!.objectID) as! Event
                
                if let modelMatch = modelMatch {
                    backgroundEvent.addToMatches(Match.insert(with: modelMatch, for: backgroundEvent, in: backgroundContext))
                }
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to match - database error")
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
