//
//  AppCoordinator.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import ReSwift
import RealmSwift

class EmailThreadDetailDataSource: NSObject, ThreadDetailDataSource {
    var rootEmails: [EmailTreeNode] = [] {
        didSet {
            
        }
    }
    
    var cellDelegate: FullEmailMessageTableViewCellDelegate?
    var indentationAndEmail: [(Int, Email)] = [] {
        didSet {
            textViewDataSources = [NSIndexPath: EmailCollapsibleTextViewDataSource]()
        }
    }
    
    private var textViewDataSources: [NSIndexPath: EmailCollapsibleTextViewDataSource] = [NSIndexPath: EmailCollapsibleTextViewDataSource]()
    private lazy var emailFormatter: EmailFormatter = EmailFormatter()
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indentationAndEmail.count
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return indentationAndEmail[indexPath.row].0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ThreadDetailViewController.fullMessageCellIdentifier) as! FullEmailMessageTableViewCell
        
        let email = indentationAndEmail[indexPath.row].1
        
        cell.indentationWidth = 10
        cell.dateLabel.text = emailFormatter.formatDate(email.date)
        cell.nameLabel.text = emailFormatter.formatName(email.from)
        cell.delegate = cellDelegate
        
        var textViewDataSource = textViewDataSources[indexPath]
        
        if textViewDataSource == nil {
            let regions = EmailCollapsibleTextViewDataSource.QuoteRanges(email.content)
            textViewDataSource = EmailCollapsibleTextViewDataSource(text: email.content, initiallyCollapsedRegions: regions)
            textViewDataSources[indexPath] = textViewDataSource!
        }
        
        cell.textViewDataSource = textViewDataSource!
        
        return cell
    }
}

class AppCoordinator: NSObject {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        
        let mailingListViewController = MailingListViewController(mailingLists: MailingList.cases.map { $0.rawValue })
        mailingListViewController.delegate = self
        self.navigationController.pushViewController(mailingListViewController, animated: false)
    }
    
    // Caches
    private var threadsViewControllerForMailingList = [MailingList: ThreadsViewController]()
}

extension AppCoordinator: MailingListViewControllerDelegate {
    func mailingListViewControllerDidSelectMailingList(mailingList: MailingListType) {
        let viewController: ThreadsViewController
        let list = MailingList(rawValue: mailingList)!
        
        let cache = RealmDataSource()
        let network = EmailThreadNetworkDataSourceImpl()
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        
        if threadsViewControllerForMailingList[list] != nil {
            viewController = threadsViewControllerForMailingList[list]!
        } else {
            viewController = ThreadsViewController(emailThreadService: service, mailingList: mailingList)
            threadsViewControllerForMailingList[list] = viewController
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension AppCoordinator: ThreadDetailViewControllerDelegate {
    func threadDetailViewControllerDidNavigateBackwards(threadDetailViewController: ThreadDetailViewController) {
    }
}
