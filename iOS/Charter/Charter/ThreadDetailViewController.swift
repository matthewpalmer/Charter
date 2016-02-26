//
//  ThreadDetailViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 31/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol TableViewCellIndentationLevelDataSource: class {
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int
}

class ThreadDetailDataSource: NSObject, UITableViewDataSource, TableViewCellIndentationLevelDataSource {
    private let service: EmailThreadService
    weak var cellDelegate: FullEmailMessageTableViewCellDelegate?
    
    private let cellIdentifier = "emailCell"
    
    private var indentationAndEmail: [(Int, Email)] = [] {
        didSet {
            textViewDataSources = [NSIndexPath: EmailCollapsibleTextViewDataSource]()
        }
    }
    
    private let rootEmail: Email
    private var textViewDataSources: [NSIndexPath: EmailCollapsibleTextViewDataSource] = [NSIndexPath: EmailCollapsibleTextViewDataSource]()
    private lazy var emailFormatter: EmailFormatter = EmailFormatter()
    
    private var emails: [Email] = [] {
        didSet {
            self.indentationAndEmail = self.computeIndentationLevels(rootEmail)
        }
    }
    
    init(tableView: UITableView, service: EmailThreadService, rootEmail: Email) {
        self.service = service
        self.rootEmail = rootEmail
        tableView.registerNib(FullEmailMessageTableViewCell.nib(), forCellReuseIdentifier: cellIdentifier)
        super.init()
        
        service.getCachedThreads(descendantsRequestForRootEmail(rootEmail)) { (emails) -> Void in
            self.emails = emails
            tableView.reloadData()
            
            if rootEmail.descendants.count > emails.count {
                // Get uncached threads if we are missing any
                service.getUncachedThreads(self.descendantsRequestForRootEmail(rootEmail), completion: { (descendants) -> Void in
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

class ThreadDetailViewController: UIViewController, UITableViewDelegate, FullEmailMessageTableViewCellDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: ThreadDetailDataSource!
    private let rootEmail: Email
    private let service: EmailThreadService
    
    init(service: EmailThreadService, rootEmail: Email) {
        self.service = service
        self.rootEmail = rootEmail
        super.init(nibName: "ThreadDetailViewController", bundle: NSBundle.mainBundle())
    }
    
    override func viewDidLoad() {
        dataSource = ThreadDetailDataSource(tableView: tableView, service: service, rootEmail: rootEmail)
        dataSource.cellDelegate = self
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        tableView.allowsSelection = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return dataSource?.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath) ?? 0
    }
    
    func didChangeCellHeight(indexPath: NSIndexPath) {
        tableView.reloadData()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func presentPopover(view: UIView, sender: UIView) {
        let size: CGSize
        
        if UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight {
            size = CGSize(width: self.view.frame.width - 140, height: self.view.frame.height - 10)
        } else {
            size = CGSize(width: self.view.frame.width - 10, height: self.view.frame.height - 140)
        }
        
        let viewController = UIViewController()
        viewController.preferredContentSize = size
        viewController.view.backgroundColor = .whiteColor()
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        viewController.popoverPresentationController!.delegate = self
        viewController.popoverPresentationController!.sourceView = sender
        viewController.popoverPresentationController!.sourceRect = sender.frame
        viewController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0) // No arrow
        
        view.frame = CGRect(origin: CGPointZero, size: CGSize(width: size.width - 10, height: size.height - 10))
        viewController.view.addSubview(view)
        
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
}
