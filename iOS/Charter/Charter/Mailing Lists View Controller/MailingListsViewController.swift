//
//  MailingListsViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 4/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol MailingListsViewControllerDelegate: class {
    func mailingListsViewControllerDidSelectMailingList(mailingList: MailingListType)
}

class MailingListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MailingListsViewControllerDelegate?
    
    let mailingLists: [MailingListType]
    
    static let reuseIdentifier = "mailingListCellIdentifier"
    
    init(mailingLists: [MailingListType]) {
        self.mailingLists = mailingLists
        super.init(nibName: "MailingListsViewController", bundle: NSBundle.mainBundle())
    }
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: MailingListsViewController.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        navigationItem.title = Localizable.Strings.mailingLists
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MailingListsViewController.reuseIdentifier)!
        cell.textLabel?.text = self.mailingLists[indexPath.row].name
        cell.accessoryType = .DisclosureIndicator
        cell.accessibilityIdentifier = self.mailingLists[indexPath.row].identifier
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
        delegate?.mailingListsViewControllerDidSelectMailingList(mailingLists[indexPath.row])
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selected, animated: true)
        }
    }
}
