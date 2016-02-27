//
//  ThreadsViewControllerDataSource.swift
//  Charter
//
//  Created by Matthew Palmer on 25/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol ThreadsViewControllerDataSource: class, UITableViewDataSource {
    var mailingList: MailingListType { get }
    var isEmpty: Bool { get }
    func refreshDataFromNetwork(completion: (Bool) -> Void)
    func emailAtIndexPath(indexPath: NSIndexPath) -> Email
    func registerTableView(tableView: UITableView)
}

class ThreadsViewControllerDataSourceImpl: NSObject, ThreadsViewControllerDataSource {
    private let service: EmailThreadService
    private let cellReuseIdentifier = "threadsCellReuseIdentifier"
    private let emptyCellReuseIdentifier = "emptyCellReuseIdentifier"
    
    let mailingList: MailingListType
    private var threads: [Email] = []
    
    private lazy var emailFormatter: EmailFormatter = EmailFormatter()
    
    init(service: EmailThreadService, mailingList: MailingListType) {
        self.service = service
        self.mailingList = mailingList
        
        super.init()
    }
    
    var isEmpty: Bool {
        return threads.count == 0
    }
    
    func registerTableView(tableView: UITableView) {
        tableView.registerNib(MessagePreviewTableViewCell.nib(), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.registerNib(NoThreadsTableViewCell.nib(), forCellReuseIdentifier: emptyCellReuseIdentifier)
        
        service.getCachedThreads(threadsRequestForPage(1)) { (emails) -> Void in
            self.threads = emails
            tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard threads.count > 0 else {
            return tableView.dequeueReusableCellWithIdentifier(emptyCellReuseIdentifier)!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! MessagePreviewTableViewCell
        let email = threads[indexPath.row]
        cell.subjectLabel.text = emailFormatter.formatSubject(email.subject)
        cell.nameLabel.text = emailFormatter.formatName(email.from)
        cell.timeLabel.text = emailFormatter.formatDate(email.date)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count > 0 ? threads.count : 1
    }
    
    func refreshDataFromNetwork(completion: (Bool) -> Void) {
        service.getUncachedThreads(threadsRequestForPage(1)) { emails in
            self.threads = emails
            completion(true)
        }
    }
    
    func emailAtIndexPath(indexPath: NSIndexPath) -> Email {
        return threads[indexPath.row]
    }
    
    private func threadsRequestForPage(page: Int) -> EmailThreadRequest {
        let builder = EmailThreadRequestBuilder()
        builder.mailingList = mailingList.identifier
        builder.inReplyTo = Either.Right(NSNull())
        builder.onlyComplete = true
        builder.pageSize = 50
        builder.page = page
        builder.sort = [("date", false)]
        return builder.build()
    }
}
