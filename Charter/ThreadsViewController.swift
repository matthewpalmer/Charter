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
    func threadsViewControllerRequestsInitialData()
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
    static let emptyCellReuseIdentifier = "threadsEmptyCell"
    
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
                if oldValue !== dataSource {
                    if tableView.numberOfRowsInSection(0) == 0 {
                        tableView.separatorStyle = .None
                    } else {
                        tableView.separatorStyle = .SingleLine
                    }
                    tableView.dataSource = dataSource
                    tableView.reloadData()
                }
            } else {
                // Reset
                dataSource = nil
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
        tableView.registerNib(MessagePreviewTableViewCell.nib(), forCellReuseIdentifier: ThreadsViewController.reuseIdentifier)
        tableView.registerNib(NoThreadsTableViewCell.nib(), forCellReuseIdentifier: ThreadsViewController.emptyCellReuseIdentifier)
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = delegate
        tableView.dataSource = dataSource
        
        tableView.addSubview(refreshControl)
        
        navigationItem.title = "Threads"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.threadsViewControllerRequestsInitialData()
    }
    
    func didRequestRefresh(sender: AnyObject) {
        delegate?.threadsViewControllerRequestsReloadedData()
    }
    
    func beginRefreshing() {
        refreshControl.beginRefreshing()
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
        if tableView != nil {
            tableView.reloadData()
        }
    }
}
