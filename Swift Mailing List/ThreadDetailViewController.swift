//
//  ThreadDetailViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import DSNestedAccordion

protocol ThreadDetailTableViewHandler: class, UITableViewDelegate, UITableViewDataSource {
    func noOfRowsInRootLevel() -> Int
    func tableView(view: UITableView!, noOfChildRowsForCellAtPath path: DSCellPath!) -> Int
    func tableView(view: UITableView!, cellForPath path: DSCellPath!) -> UITableViewCell!
}

protocol ThreadDetailViewControllerDelegate: class {
    func threadDetailViewControllerDidNavigateBackwards(threadDetailViewController: ThreadDetailViewController)
}

class ThreadDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    static let fullMessageCellIdentifier = "fullMessageCellId"
    
    weak var handler: ThreadDetailTableViewHandler?
    weak var delegate: ThreadDetailViewControllerDelegate?
    
    init() {
        super.init(nibName: "ThreadsViewController", bundle: NSBundle.mainBundle())
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            // Pressed 'Back' from this screen. Need to update our route history.
            delegate?.threadDetailViewControllerDidNavigateBackwards(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.registerNib(FullEmailMessageTableViewCell.nib(), forCellReuseIdentifier: ThreadDetailViewController.fullMessageCellIdentifier)
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = handler
        tableView.delegate = handler
    }
    
    override func viewDidLoad() {

    }
    
    func reload() {
        if tableView != nil {
            tableView.reloadData()
        }
    }
}
