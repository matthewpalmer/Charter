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
    var title: String { get }
    var isEmpty: Bool { get }
    func refreshDataFromNetwork(completion: (Bool) -> Void)
    func emailAtIndexPath(indexPath: NSIndexPath) -> Email
    func registerTableView(tableView: UITableView)
}

extension ThreadsViewControllerDataSource {
    var title: String {
        return mailingList.name
    }
}

class ThreadsViewControllerDataSourceImpl: NSObject, ThreadsViewControllerDataSource {
    private let service: EmailThreadService
    private let labelService: LabelService
    private let cellReuseIdentifier = "threadsCellReuseIdentifier"
    private let emptyCellReuseIdentifier = "emptyCellReuseIdentifier"
    
    let mailingList: MailingListType
    private var threads: [Email] = []
    
    private lazy var emailFormatter: EmailFormatter = EmailFormatter()
    
    init(service: EmailThreadService, mailingList: MailingListType, labelService: LabelService) {
        self.service = service
        self.mailingList = mailingList
        self.labelService = labelService
        
        super.init()
    }
    
    var isEmpty: Bool {
        return threads.count == 0
    }
    
    func registerTableView(tableView: UITableView) {
        tableView.registerNib(MessagePreviewTableViewCell.nib(), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.registerNib(NoThreadsTableViewCell.nib(), forCellReuseIdentifier: emptyCellReuseIdentifier)
        
        service.getCachedThreads(threadsRequestForPage(1)) { [unowned self] (emails) -> Void in
            self.threads = emails
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard threads.count > 0 else {
            tableView.backgroundColor = UIColor.whiteColor()
            return tableView.dequeueReusableCellWithIdentifier(emptyCellReuseIdentifier)!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! MessagePreviewTableViewCell
        let email = threads[indexPath.row]
        let formattedSubject = emailFormatter.formatSubject(email.subject)
        let labels = emailFormatter.labelsInSubject(formattedSubject)
        
        cell.setName(emailFormatter.formatName(email.from))
        cell.setTime(emailFormatter.formatDate(email.date))
        cell.setMessageCount("\(email.descendants.count)")
        cell.setLabels(labels.map { (labelService.formattedStringForLabel($0), labelService.colorForLabel($0), UIColor.whiteColor()) })
        cell.setSubject(emailFormatter.subjectByRemovingLabels(formattedSubject))
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard threads.count > 0 else {
            tableView.backgroundColor = UIColor.whiteColor()
            return 1
        }
        
        tableView.backgroundColor = UIColor(hue:0.67, saturation:0.02, brightness:0.96, alpha:1)
        return threads.count
    }
    
    func refreshDataFromNetwork(completion: (Bool) -> Void) {
        service.refreshCache(threadsRequestForPage(1)) { emails in
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
