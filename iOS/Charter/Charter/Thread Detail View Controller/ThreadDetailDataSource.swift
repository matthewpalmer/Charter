//
//  ThreadDetailDataSource.swift
//  Charter
//
//  Created by Matthew Palmer on 27/02/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

/// Used to redirect the UITableViewDelegate indentation level to a data source.
protocol TableViewCellIndentationLevelDataSource: class {
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int
}

protocol ThreadDetailDataSource: class, UITableViewDataSource, TableViewCellIndentationLevelDataSource {
    var cellDelegate: FullEmailMessageTableViewCellDelegate? { get set }
    func registerTableView(tableView: UITableView)
}

class ThreadDetailDataSourceImpl: NSObject, ThreadDetailDataSource {
    private let service: EmailThreadService
    weak var cellDelegate: FullEmailMessageTableViewCellDelegate?
    
    private let cellIdentifier = "emailCell"
    
    private var indentationAndEmail: [(Int, Email)] = [] {
        didSet {
            textViewDataSources = [NSIndexPath: EmailTextRegionViewDataSource]()
        }
    }
    
    private let codeBlockParser: CodeBlockParser
    private let rootEmail: Email
    private var textViewDataSources: [NSIndexPath: EmailTextRegionViewDataSource] = [NSIndexPath: EmailTextRegionViewDataSource]()
    private lazy var emailFormatter: EmailFormatter = EmailFormatter()
    
    private var emails: [Email] = [] {
        didSet {
            self.indentationAndEmail = self.computeIndentationLevels(rootEmail)
        }
    }
    
    init(service: EmailThreadService, rootEmail: Email, codeBlockParser: CodeBlockParser) {
        self.service = service
        self.rootEmail = rootEmail
        self.codeBlockParser = codeBlockParser
        super.init()
    }
    
    func registerTableView(tableView: UITableView) {
        tableView.registerNib(FullEmailMessageTableViewCell.nib(), forCellReuseIdentifier: cellIdentifier)
        
        service.getCachedThreads(descendantsRequestForRootEmail(rootEmail)) { (emails) -> Void in
            self.emails = emails
            tableView.reloadData()
            
            if self.rootEmail.descendants.count > emails.count {
                // Get uncached threads if we are missing any
                self.service.refreshCache(self.descendantsRequestForRootEmail(self.rootEmail), completion: { (descendants) -> Void in
                    self.emails = descendants
                    tableView.reloadData()
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return indentationAndEmail[indexPath.row].0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! FullEmailMessageTableViewCell
        let email = indentationAndEmail[indexPath.row].1
        
        cell.indentationLevel = indentationAndEmail[indexPath.row].0
        cell.indentationWidth = 10
        cell.setDate(emailFormatter.formatDate(email.date))
        cell.setName(emailFormatter.formatName(email.from))
        cell.delegate = cellDelegate
        
        var textViewDataSource = textViewDataSources[indexPath]
        
        let content = emailFormatter.formatContent(email.content)
        
        if textViewDataSource == nil {
            let regions = EmailQuoteRanges(content)
            textViewDataSource = EmailTextRegionViewDataSource(text: content, initiallyCollapsedRegions: regions, codeBlockParser: codeBlockParser)
            textViewDataSources[indexPath] = textViewDataSource!
        }
        
        cell.textViewDataSource = textViewDataSource!
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indentationAndEmail.count
    }
    
    private func descendantsRequestForRootEmail(rootEmail: Email) -> EmailThreadRequest {
        let builder = EmailThreadRequestBuilder()
        builder.idIn = Array(rootEmail.descendants.map { $0.id })
        builder.page = 1
        builder.pageSize = 1000
        builder.onlyComplete = true
        return builder.build()
    }
    
    private func computeIndentationLevels(rootEmail: Email) -> [(Int, Email)] {
        var children = [String: [Email]]()
        for email in rootEmail.descendants {
            if let inReplyTo = email.inReplyTo {
                if children[inReplyTo.id] == nil {
                    children[inReplyTo.id] = []
                }
                
                children[inReplyTo.id]!.append(email)
            }
        }
        
        for id in children.keys {
            children[id] = children[id]?.sort { $0.date.compare($1.date) == NSComparisonResult.OrderedAscending }
        }
        
        func indentationLevel(root: Email, indentLevel: Int) -> [(Int, Email)] {
            var list = [(Int, Email)]()
            for child in children[root.id] ?? [] {
                if child.id != root.id {
                    list.appendContentsOf(indentationLevel(child, indentLevel: indentLevel + 1))
                }
            }
            return [(indentLevel, root)] + list
        }
        
        let thread = indentationLevel(rootEmail, indentLevel: 0)
        return thread
    }
}
