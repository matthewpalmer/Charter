//
//  ThreadDetailViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol ThreadDetailViewControllerDataSource: class {
    func threadDetailViewControllerEmailForIndexPath(threadDetailViewController: ThreadDetailViewController, indexPath: NSIndexPath) -> Email
    func threadDetailViewControllerNumberOfEmailsInSection(threadDetailViewController: ThreadDetailViewController, section: Int) -> Int
}

class ThreadDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private let reuseIdentifier = "threadDetailCellIdentifier"
    
    weak var dataSource: ThreadDetailViewControllerDataSource?
    
    init() {
        super.init(nibName: "ThreadsViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.dataSource = self
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let email = dataSource!.threadDetailViewControllerEmailForIndexPath(self, indexPath: indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = email.content
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource!.threadDetailViewControllerNumberOfEmailsInSection(self, section: section)
    }
    
    func reload() {
        if tableView != nil {
            tableView.reloadData()
        }
    }
}
