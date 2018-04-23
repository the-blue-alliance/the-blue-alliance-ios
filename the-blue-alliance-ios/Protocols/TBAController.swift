//
//  TBAController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 3/18/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TBAKit
import PureLayout

protocol Container {
    var viewControllers: [Persistable & Refreshable] { get set }
    var containerViews: [UIView] { get set }

    var segmentedControl: UISegmentedControl? { get set }
    
    func switchedToIndex(_ index: Int)
}

extension Container {
    
    func updateSegmentedControlViews() {
        if segmentedControl == nil, containerViews.count == 1 {
            show(view: containerViews.first!)
        } else if let segmentedControl = segmentedControl, containerViews.count > segmentedControl.selectedSegmentIndex {
            show(view: containerViews[segmentedControl.selectedSegmentIndex])
        }
    }
    
    private func show(view showView: UIView) {
        var switchedIndex = 0
        for (index, containerView) in containerViews.enumerated() {
            let shouldHide = !(containerView == showView)
            if !shouldHide {
                let refreshViewController = viewControllers[index]
                if refreshViewController.shouldRefresh() {
                    refreshViewController.refresh()
                }
                switchedIndex = index
            }
            containerView.isHidden = shouldHide
        }
        switchedToIndex(switchedIndex)
    }

    func cancelRefreshes() {
        viewControllers.forEach {
            $0.cancelRefresh()
        }
    }

}

protocol Persistable: AnyObject {
    var persistentContainer: NSPersistentContainer! { get set }
    
    var dataView: UIView { get }
    var noDataView: UIView? { get set }
}

extension Persistable {
    
    func showNoDataView(with text: String?) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let noDataViewController = mainStoryboard.instantiateViewController(withIdentifier: "NoDataViewController") as! NoDataViewController
        guard let noDataView = noDataViewController.view else {
            fatalError("Failed to get no data view")
        }
        noDataView.backgroundColor = .backgroundGray

        if let text = text {
            noDataViewController.textLabel?.text = text
        } else {
            noDataViewController.textLabel?.text = "No data to display"
        }
        
        noDataView.alpha = 0
        if let tableView = dataView as? UITableView {
            tableView.backgroundView = noDataView
        } else if let collectionView = dataView as? UICollectionView {
            collectionView.backgroundView = noDataView
        } else {
            dataView.insertSubview(noDataView, at: 0)
            DispatchQueue.main.async {
                noDataView.autoPinEdgesToSuperviewEdges()
            }
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            noDataView.alpha = 1.0
        })
        self.noDataView = noDataView
    }
    
    func removeNoDataView() {
        if let tableView = dataView as? UITableView {
            DispatchQueue.main.async {
                tableView.backgroundView = nil
            }
        } else if let collectionView = dataView as? UICollectionView {
            DispatchQueue.main.async {
                collectionView.backgroundView = nil
            }
        } else {
            noDataView?.removeFromSuperview()
        }
    }

}

protocol Observable: Persistable {
    associatedtype ManagedType: NSManagedObject
    
    var contextObserver: CoreDataContextObserver<ManagedType> { get }
    var observerPredicate: NSPredicate { get }
}

extension Observable {
    
    // Make observerPredicate optional
    var observerPredicate: NSPredicate {
        return NSPredicate()
    }
}

protocol Alertable {
}

extension Alertable where Self: UIViewController {
    
    func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

class ContainerViewController: UIViewController, Container, Persistable, Alertable {

    var persistentContainer: NSPersistentContainer!
    var dataView: UIView {
        return view
    }
    var noDataView: UIView?
    private lazy var setupSegmentedControlViews: Void = {
        [unowned self] in
        self.updateSegmentedControlViews()
    }()
    
    var viewControllers: [Persistable & Refreshable] = [] {
        didSet {
            if let persistentContainer = persistentContainer {
                for controller in viewControllers {
                    let c = controller
                    c.persistentContainer = persistentContainer
                }
            }
        }
    }
    var containerViews: [UIView] = []
    
    @IBOutlet var navigationTitleLabel: UILabel? {
        didSet {
            navigationTitleLabel?.textColor = .white
        }
    }
    @IBOutlet var navigationDetailLabel: UILabel? {
        didSet {
            navigationDetailLabel?.textColor = .white
        }
    }
    
    @IBOutlet var segmentedControl: UISegmentedControl?
    @IBOutlet var segmentedControlView: UIView? {
        didSet {
            segmentedControlView?.backgroundColor = .primaryBlue
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Equlivent of doing a dispatch_once in Obj-C
        // Only setup the segmented control views on view did appear the first time
        _ = setupSegmentedControlViews
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // TODO: Consider... if a view is presented over top of the current view but no action is taken
        // We don't want to cancel refreshes in that situation
        cancelRefreshes()
    }
    
    @IBAction func segmentedControlValueChanged(sender: Any) {
        cancelRefreshes()
        updateSegmentedControlViews()
    }
    
    func switchedToIndex(_ index: Int) {}

}

class TBAViewController: UIViewController, Persistable, Refreshable, Alertable {

    var persistentContainer: NSPersistentContainer!
    var requests: [URLSessionDataTask] = []
    var dataView: UIView {
        return view
    }
    var noDataView: UIView?
    @IBOutlet var scrollView: UIScrollView!
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = scrollView.refreshControl
    }
    
    @objc func refresh() {
        fatalError("Implement this downstream")
    }
    
    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }
}

class TBATableViewController: UITableViewController, Persistable, Refreshable, Alertable {

    let basicCellReuseIdentifier = "BasicCell"
    var persistentContainer: NSPersistentContainer!
    var requests: [URLSessionDataTask] = []
    var dataView: UIView {
        return tableView
    }
    var noDataView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64.0
        tableView.backgroundColor = .backgroundGray
        tableView.tableFooterView = UIView.init(frame: .zero)
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: basicCellReuseIdentifier)
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        fatalError("Implement this downstream")
    }
    
    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }
    
}

class TBACollectionViewController: UICollectionViewController, Persistable, Refreshable, Alertable {
    
    let basicCellReuseIdentifier = "BasicCell"
    var persistentContainer: NSPersistentContainer!
    var requests: [URLSessionDataTask] = []
    var dataView: UIView {
        return collectionView!
    }
    var noDataView: UIView?
    var refreshControl: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .backgroundGray
        collectionView?.delegate = self
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: basicCellReuseIdentifier)

        collectionView!.refreshControl = UIRefreshControl()
        collectionView!.refreshControl!.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl = collectionView!.refreshControl
    }
    
    @objc func refresh() {
        fatalError("Implement this downstream")
    }
    
    func shouldNoDataRefresh() -> Bool {
        fatalError("Implement this downstream")
    }
    
}

// MARK: Refreshing Protocol

// Refreshable is a class-only protocol since we're mutating variables within the class that implements it
// Value types cannot implement the Refreshable protocol
protocol Refreshable: AnyObject {
    var requests: [URLSessionDataTask] { get set }
    var refreshControl: UIRefreshControl? { get set }
    
    func refresh()
    func shouldNoDataRefresh() -> Bool
}

extension Refreshable {
    
    var isRefreshing: Bool {
        // We're not refreshing if our requests array is empty
        return !requests.isEmpty
    }
    
    func shouldRefresh() -> Bool {
        return shouldNoDataRefresh() && !isRefreshing
    }
    
    // TODO: Add a method to add an observer on a single core data object for changes
    
    func cancelRefresh() {
        if requests.isEmpty {
            return
        }
        
        for request in requests {
            request.cancel()
        }
        requests.removeAll()
        updateRefresh()
    }
    
    func addRequest(request: URLSessionDataTask) {
        if requests.contains(request) {
            return
        }
        requests.append(request)
        updateRefresh()
    }
    
    func removeRequest(request: URLSessionDataTask) {
        guard let index = requests.index(of: request) else {
            return
        }
        requests.remove(at: index)
        updateRefresh()

        if requests.isEmpty {
            // TODO: Do we actually need this?
            // Reload our data sources locally
            DispatchQueue.main.async {
                if let tableViewController = self as? UITableViewController {
                    tableViewController.tableView.reloadData()
                } else if let collectionViewController = self as? UICollectionViewController {
                    collectionViewController.collectionView?.reloadData()
                }
            }
        }
    }
    
    private func updateRefresh() {
        DispatchQueue.main.async {
            if self.isRefreshing {
                self.refreshControl?.beginRefreshing()
            } else {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
}
