//
//  MailingListViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 4/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol MailingListViewControllerDelegate: class {
    func mailingListViewControllerDidSelectMailingList(mailingList: MailingListType)
}

class MailingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MailingListViewControllerDelegate?
    
    let mailingLists: [MailingListType]
    
    static let reuseIdentifier = "mailingListCellIdentifier"
    
    init(mailingLists: [MailingListType]) {
        self.mailingLists = mailingLists
        super.init(nibName: "MailingListViewController", bundle: NSBundle.mainBundle())
    }
    
    deinit {
        print("deinit mlvc")
    }
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: MailingListViewController.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.title = "Mailing Lists"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MailingListViewController.reuseIdentifier)!
        cell.textLabel?.text = self.mailingLists[indexPath.row].name
        cell.accessoryType = .DisclosureIndicator
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mailingLists.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(nil, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        delegate?.mailingListViewControllerDidSelectMailingList(mailingLists[indexPath.row])
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selected, animated: true)
        }
    }
}
