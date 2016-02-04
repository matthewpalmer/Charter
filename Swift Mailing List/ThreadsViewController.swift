//
//  ThreadsViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import ReSwift

protocol ThreadsViewControllerDelegate: class, UITableViewDelegate {
    func threadsViewControllerRequestsReloadedData()
    func threadsViewControllerDidNavigateBackwards(threadsViewController: ThreadsViewController)
}

protocol ThreadsViewControllerDataSource: class, UITableViewDataSource {
    func mailingListTitle() -> String
    func rootEmailAtIndexPath(indexPath: NSIndexPath) -> Email
}

class ThreadsViewController: UIViewController, UITableViewDelegate {
    typealias StoreSubscriberStateType = AppState
    
    static let reuseIdentifier = "threadsCellReuseIdentifier"
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: ThreadsViewControllerDelegate? {
        didSet {
            if tableView != nil {
                tableView.delegate = delegate
            }
        }
    }
    
    weak var dataSource: ThreadsViewControllerDataSource? {
        didSet {
            if tableView != nil {
                tableView.dataSource = dataSource
                tableView.reloadData()
            }
        }
    }
    
    init() {
        super.init(nibName: "ThreadsViewController", bundle: NSBundle.mainBundle())
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            // Pressed 'Back' from this screen. Need to update our route history.
            delegate?.threadsViewControllerDidNavigateBackwards(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "didRequestRefresh:", forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ThreadsViewController.reuseIdentifier)
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        delegate?.threadsViewControllerRequestsReloadedData()
        
        tableView.addSubview(refreshControl)
        
        navigationItem.title = "Threads"
    }
    
    func didRequestRefresh(sender: AnyObject) {
        beginRefreshing()
    }
    
    func beginRefreshing() {
        refreshControl.beginRefreshing()
        delegate?.threadsViewControllerRequestsReloadedData()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
}
