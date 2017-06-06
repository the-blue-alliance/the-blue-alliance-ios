//
//  EventStatsViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/4/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import CoreData
import TBAKit
import UIKit
import React

class EventStatsViewController: TBAViewController {
    
    var event: Event!
    override var persistentContainer: NSPersistentContainer! {
        didSet {
            registerForChangeNotifications { (obj) in
                if obj == self.event {
                    DispatchQueue.main.async {
                        self.updateEventStatsView()
                    }
                }
            }
        }
    }
    private var eventStatsView: RCTRootView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleInterface()
    }
    
    // MARK: Interface Methods
    
    func styleInterface() {
        scrollView.backgroundColor = .backgroundGray

        updateEventStatsView()
    }
    
    func updateEventStatsView() {
        // Event stats only exist for 2016 and onward
        if Int(event.year) < 2016 {
            return
        }
        
        // If the event stats view already exists, don't set it up again
        // Only update the properties for the view
        if let _ = eventStatsView {
            eventStatsView?.appProperties = event.insights
            return
        }
        
        guard let jsCodeLocation = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index.ios", fallbackResource: nil) else {
            self.showNoDataView(with: "Unable to load event stats")
            return
        }
        
        
        let moduleName = "EventInsights\(event!.year)"
        
        guard let rootView = RCTRootView(bundleURL: jsCodeLocation, moduleName: moduleName, initialProperties: event.insights, launchOptions: [:]) else {
            self.showNoDataView(with: "Unable to load event stats")
            return
        }
        eventStatsView = rootView
        eventStatsView!.delegate = self
        eventStatsView!.sizeFlexibility = .height
        
        scrollView.addSubview(eventStatsView!)
        eventStatsView!.autoMatch(.width, to: .width, of: scrollView)
        eventStatsView!.autoPinEdgesToSuperviewEdges()
    }
    
    // MARK: Refresh
    
    override func shouldNoDataRefresh() -> Bool {
        return event.insights == nil
    }
    
    override func refresh() {
        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBAEvent.fetchInsights(event.key!, completion: { (insights, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh event stats - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundEvent = backgroundContext.object(with: self.event.objectID) as! Event
                backgroundEvent.insights = insights
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh event stats - database error")
                }
                
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }
    
}

extension EventStatsViewController: RCTRootViewDelegate {
    
    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        rootView.autoSetDimension(.height, toSize: rootView.intrinsicContentSize.height)
    }
    
}
