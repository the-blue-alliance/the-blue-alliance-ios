//
//  DistrictsTableViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 5/13/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TBAKit

class DistrictsTableViewController: TBATableViewController {
    
    override var persistentContainer: NSPersistentContainer! {
        didSet {
            updateDataSource()
        }
    }
    internal var year: Int? {
        didSet {
            cancelRefresh()
            updateDataSource()
            
            if shouldNoDataRefresh() {
                refresh()
            }
        }
    }
    
    var districtSelected: ((District) -> ())?

    // MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    }
    
    // MARK: - Refreshing
    
    override func refresh() {
        guard let year = year else {
            return
        }

        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBADistrict.fetchDistricts(year: year) { (districts, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh districts - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                districts?.forEach({ (modelDistrict) in
                    _ = District.insert(with: modelDistrict, in: backgroundContext)
                })
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh districts - database error")
                }
                
                self.removeRequest(request: request!)
            })
        }
        addRequest(request: request!)
    }
    
    override func shouldNoDataRefresh() -> Bool {
        if let districts = dataSource?.fetchedResultsController.fetchedObjects, districts.isEmpty {
            return true
        }
        return false
    }
    
    // MARK: UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let district = dataSource?.object(at: indexPath)
        if let district = district, let districtSelected = districtSelected {
            districtSelected(district)
        }
    }
    
    // MARK: Table View Data Source
    
    fileprivate var dataSource: TableViewDataSource<District, DistrictsTableViewController>?
    
    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer else {
            return
        }
        
        let fetchRequest: NSFetchRequest<District> = District.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        setupFetchRequest(fetchRequest)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: basicCellReuseIdentifier, fetchedResultsController: frc, delegate: self)
    }
    
    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }
    
    fileprivate func setupFetchRequest(_ request: NSFetchRequest<District>) {
        guard let year = year else {
            return
        }
        request.predicate = NSPredicate(format: "year == %ld", year)
    }
    
}

extension DistrictsTableViewController: TableViewDataSourceDelegate {
    
    func configure(_ cell: UITableViewCell, for object: District, at indexPath: IndexPath) {
        cell.textLabel?.text = object.name
        // TODO: Convert to some custom cell... show # of events if non-zero
    }
    
    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "Unable to load districts")
    }
    
    func hideNoDataView() {
        removeNoDataView()
    }

}
