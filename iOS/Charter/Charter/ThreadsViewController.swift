//
//  ThreadsViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import ReSwift

class ThreadsViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private let emailThreadService: EmailThreadService
    private let mailingList: MailingListType
    
    private var dataSource: ThreadsViewControllerDataSource!
    
    init(emailThreadService: EmailThreadService, mailingList: MailingListType) {
        self.emailThreadService = emailThreadService
        self.mailingList = mailingList
        super.init(nibName: "ThreadsViewController", bundle: nil)
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
        self.dataSource = ThreadsViewControllerDataSource(tableView: tableView, service: emailThreadService, mailingList: mailingList)
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        navigationItem.title = mailingList.name
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.addSubview(refreshControl)
        updateSeparatorStyle()
    }
    
    private func updateSeparatorStyle() {
        if dataSource.isEmpty {
            tableView.separatorStyle = .None
        }
    }
    
    func didRequestRefresh(sender: AnyObject) {
        dataSource.refreshDataFromNetwork { (success) -> Void in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.updateSeparatorStyle()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if dataSource.isEmpty {
            cell.userInteractionEnabled = false
        }
    }
}
