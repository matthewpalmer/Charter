//
//  ThreadsSearchViewControllerDataSource.swift
//  Charter
//
//  Created by Matthew Palmer on 17/03/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class ThreadsSearchViewControllerDataSource: NSObject, ThreadsViewControllerDataSource {
    var emails: [Email] = [] {
        didSet {
            // Reset labels
            emails.forEach { email in
                let textLabels = emailFormatter.labelsInSubject(emailFormatter.formatSubject(email.subject))
                
                let match: Match
                if email.subject.lowercaseString.containsString(searchPhrase.lowercaseString) {
                    match = .Subject(searchPhrase)
                } else if email.from.lowercaseString.containsString(searchPhrase.lowercaseString) {
                    match = .From(searchPhrase)
                } else {
                    match = .Content(searchPhrase) // Assume that if we have the email it must match on one of these three fields.
                }
                
                var labels: [(string: String, textColor: UIColor, backgroundColor: UIColor)] = [
                    (string: match.label().0, textColor: UIColor.whiteColor(), backgroundColor: match.label().1)
                ]
                
                labels
                    .appendContentsOf(
                        textLabels.map { (labelService.formattedStringForLabel($0), labelService.colorForLabel($0), UIColor.whiteColor()) }
                )
                
                self.labels[email] = labels
            }
        }
    }
    
    var labels: [Email: [(string: String, textColor: UIColor, backgroundColor: UIColor)]] = [Email: [(string: String, textColor: UIColor, backgroundColor: UIColor)]]()
    
    let searchPhrase: String
    let mailingList: MailingListType
    let service: EmailThreadService
    let labelService: LabelService
    let request: UncachedThreadRequest
    
    let emailFormatter = EmailFormatter()
    
    private let cellReuseIdentifier = "messageCell"
    private let emptyCellReuseIdentifier = "searchInProgressCell"
    
    var isEmpty: Bool {
        return emails.count == 0
    }
    
    var isSearching: Bool = false
    
    var title: String = ""
    
    init(service: EmailThreadService, labelService: LabelService, mailingList: MailingListType, searchPhrase: String) {
        self.searchPhrase = searchPhrase
        self.mailingList = mailingList
        self.labelService = labelService
        let builder = SearchRequestBuilder()
        // Always do exact match search (tokenized searches are pretty useless in this context)
        builder.text = "\"" + searchPhrase + "\""
        builder.mailingList = mailingList.identifier
        self.request = builder.build()
        self.service = service
        self.title = "“\(searchPhrase)”"
        super.init()
    }
    
    func refreshDataFromNetwork(completion: (Bool) -> Void) {
        isSearching = true
        service.getUncachedThreads(self.request) { emails in
            self.isSearching = false
            self.emails = emails
            
            completion(true)
        }
    }
    
    func emailAtIndexPath(indexPath: NSIndexPath) -> Email {
        return emails[indexPath.row]
    }
    
    func registerTableView(tableView: UITableView) {
        tableView.registerNib(MessagePreviewTableViewCell.nib(), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.registerNib(SearchInProgressTableViewCell.nib(), forCellReuseIdentifier: emptyCellReuseIdentifier)
        
        refreshDataFromNetwork { success in
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isEmpty else {
            tableView.backgroundColor = UIColor.whiteColor()
            return 1
        }
        
        tableView.backgroundColor = UIColor(hue:0.67, saturation:0.02, brightness:0.96, alpha:1)
        return emails.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard !isEmpty else {
            let cell = tableView.dequeueReusableCellWithIdentifier(emptyCellReuseIdentifier) as! SearchInProgressTableViewCell
            if isSearching {
                cell.activityIndicator.startAnimating()
                cell.searchLabel.text = Localizable.Strings.searching
                cell.activityIndicator.hidden = false
            } else {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.hidden = true
                cell.searchLabel.text = Localizable.Strings.noResults
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! MessagePreviewTableViewCell
        let email = emailAtIndexPath(indexPath)
        let formattedSubject = emailFormatter.subjectByRemovingLabels(
                emailFormatter.formatSubject(email.subject)
            )
        
        cell.setName(emailFormatter.formatName(email.from))
        cell.setTime(emailFormatter.formatDate(email.date))
        cell.setMessageCount("\(email.descendants.count)")
        
        let labels: [(string: String, textColor: UIColor, backgroundColor: UIColor)] = self.labels[email] ?? []
        cell.setLabels(labels)
        cell.setSubject(formattedSubject)
        
        return cell
    }
}

private enum Match {
    case Subject(String)
    case From(String)
    case Content(String)
    
    func label() -> (String, UIColor) {
        let text: String
        let color: UIColor = UIColor(red:0.99, green:0.43, blue:0.22, alpha:1)
        
        switch self {
        case .Subject(_):
            text = Localizable.Strings.subject
        case .From(_):
            text = Localizable.Strings.author
        case .Content(_):
            text = Localizable.Strings.content
        }
        
        return (text.lowercaseString, color)
    }
}
