//
//  AppCoordinator.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import ReSwift

class EmailThreadDetailDataSource: NSObject, ThreadDetailDataSource {
    var rootEmails: [EmailTreeNode] = [] {
        didSet {
            indentationForEmail = [Email: Int]()
            HTMLContentForEmail = [Email: String]()
            textViewDataSources = [NSIndexPath: EmailCollapsibleTextViewDataSource]()
            orderedEmails = orderedEmailsFromTree(rootEmails).map { $0.email }
        }
    }
    
    var cellDelegate: FullEmailMessageTableViewCellDelegate?
    private var HTMLContentForEmail: [Email: String] = [Email: String]()
    private var orderedEmails: [Email] = []
    private var indentationForEmail = [Email: Int]()
    private var textViewDataSources: [NSIndexPath: EmailCollapsibleTextViewDataSource] = [NSIndexPath: EmailCollapsibleTextViewDataSource]()
    private lazy var emailFormatter: EmailFormatter = EmailFormatter()
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedEmails.count
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        let indent = indentationForEmail[orderedEmails[indexPath.row]]
        return indent ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ThreadDetailViewController.fullMessageCellIdentifier) as! FullEmailMessageTableViewCell
        
        let email = orderedEmails[indexPath.row] // emailForTreePath(rootEmails, path: path).email
        
        cell.indentationWidth = 10
        cell.dateLabel.text = emailFormatter.formatDate(email.headers.date)
        cell.nameLabel.text = emailFormatter.formatName(email.headers.from)
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
    
    private func orderedEmailsFromTree(rootEmails: [EmailTreeNode]) -> [EmailTreeNode] {
        func getOrderedEmailsAndSetNestingLevel(level: Int, rootEmails: [EmailTreeNode]) -> [EmailTreeNode] {
            guard let _ = rootEmails.first else {
                return []
            }
            
            // The root, followed by all its children
            var array: [EmailTreeNode] = []
            
            for rootEmail in rootEmails {
                array.append(rootEmail)
                indentationForEmail[rootEmail.email] = level
                array.appendContentsOf(getOrderedEmailsAndSetNestingLevel(level + 1, rootEmails: rootEmail.children))
            }
            
            return array
        }
        
        return getOrderedEmailsAndSetNestingLevel(0, rootEmails: rootEmails)
    }
}

class EmailFormatter {
    private lazy var squareBracketRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^\\[.*\\]", options: .CaseInsensitive)
    }()
    
    private lazy var leadingSpaceRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^\\s+", options: .CaseInsensitive)
    }()
    
    private lazy var withinParenthesesRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "\\((.*)\\)", options: .CaseInsensitive)
    }()
    
    private lazy var sourceDateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "ccc, dd MMM yyyy HH:mm:ss Z"
        return df
    }()
    
    private lazy var destinationDateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.dateFormat = "d MMM"
        return df
    }()
    
    private lazy var leadingPunctuationRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^\\W+", options: .CaseInsensitive)
    }()
    
    func formatSubject(subject: String) -> String {
        let noSquareBrackets = squareBracketRegex.stringByReplacingMatchesInString(subject, options: [], range: NSMakeRange(0, subject.characters.count), withTemplate: "")
        let noLeadingPunctuation = leadingPunctuationRegex.stringByReplacingMatchesInString(noSquareBrackets, options: [], range: NSMakeRange(0, noSquareBrackets.characters.count), withTemplate: "")
        let noLeadingSpaces = leadingSpaceRegex.stringByReplacingMatchesInString(noLeadingPunctuation, options: [], range: NSMakeRange(0, noLeadingPunctuation.characters.count), withTemplate: "")
        return noLeadingSpaces
    }
    
    func formatName(name: String) -> String {
        let firstMatch = withinParenthesesRegex.firstMatchInString(name, options: [], range: NSMakeRange(0, name.characters.count))
        let range = firstMatch?.rangeAtIndex(1) ?? NSMakeRange(0, name.characters.count)
        let withinParens = (name as NSString).substringWithRange(range)
        return withinParens
    }
    
    func formatDate(date: String) -> String {
        if let date = sourceDateFormatter.dateFromString(date) {
            return destinationDateFormatter.stringFromDate(date)
        } else {
            return ""
        }
    }
}

class ThreadsTableViewDataSource: NSObject, ThreadsViewControllerDataSource {
    private let emails: [Email]
    private let title: String
    
    // Conflicted about this data source taking in the entire app state
    init(state: AppState) {
        title = state.selectedMailingList!.rawValue.name
        
        self.emails = PartitionEmailsIntoTreeForest(
            state.emailList.filter { $0.mailingList == state.selectedMailingList! }
            ).map { $0.email }//.reverse()
    }
    
    private lazy var emailFormatter: EmailFormatter = EmailFormatter()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ThreadsViewController.reuseIdentifier, forIndexPath: indexPath) as! MessagePreviewTableViewCell
        let email = emails[indexPath.row]
        
        cell.subjectLabel.text = emailFormatter.formatSubject(email.headers.subject)
        cell.nameLabel.text = emailFormatter.formatName(email.headers.from)
        cell.timeLabel.text = emailFormatter.formatDate(email.headers.date)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    func mailingListTitle() -> String {
        return title
    }
    
    func rootEmailAtIndexPath(indexPath: NSIndexPath) -> Email {
        return emails[indexPath.row]
    }
}

class AppCoordinator: NSObject, StoreSubscriber {
    let navigationController: UINavigationController
    
    lazy var mailingListViewController: MailingListViewController = {
        let viewController = MailingListViewController(mailingLists: MailingList.cases.map { $0.rawValue })
        viewController.delegate = self
        return viewController
    }()
    
    lazy var threadsViewController: ThreadsViewController = {
        let viewController = ThreadsViewController()
        viewController.delegate = self
        return viewController
    }()

    lazy var detailTableViewDataSource: EmailThreadDetailDataSource = {
        return EmailThreadDetailDataSource()
    }()
    
    lazy var threadDetailViewController: ThreadDetailViewController = {
        return self.constructThreadDetailViewController()
    }()
    
    func constructThreadDetailViewController() -> ThreadDetailViewController {
        let viewController = ThreadDetailViewController()
        viewController.dataSource = self.detailTableViewDataSource
        self.detailTableViewDataSource.cellDelegate = viewController
        viewController.delegate = self
        return viewController
    }
    
    var threadsTableViewDataSource: ThreadsTableViewDataSource? {
        didSet {
            self.threadsViewController.dataSource = threadsTableViewDataSource
        }
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        super.init()
        
        mainStore.subscribe(self)
        mainStore.dispatch(MoveTo(route: .MailingLists))
    }
    
    func newState(state: AppState) {
        if let nextRoute = state.nextRoute {
            route(nextRoute, routeHistory: state.routeHistory)
        }
        
        if state.routeHistory.last == .ThreadDetail {
            let emailsInList = state.emailList.filter { $0.mailingList == state.selectedMailingList }
            let forest = PartitionEmailsIntoTreeForest(emailsInList)
            detailTableViewDataSource.rootEmails = forest
                .filter { $0.email.headers.messageID == state.selectedThreadWithRootMessageID }
            
            if threadDetailViewController.tableView != nil && state.selectedThreadWithRootMessageID != nil {
                threadDetailViewController.tableView.reloadData()
            }
        }
        
        if state.routeHistory.last == .Threads && state.selectedMailingList != nil {
            if let isRefreshing = state.mailingListIsRefreshing[state.selectedMailingList!] where isRefreshing == true {
//                threadsViewController.beginRefreshing()
            } else {
                threadsViewController.endRefreshing()
            }
            
            if state.emailList.count > 0 {
                threadsTableViewDataSource = ThreadsTableViewDataSource(state: state)
            }
            
        }
    }
    
    func route(nextRoute: Route, routeHistory: [Route]) {
        defer {
            mainStore.dispatch(NextRouteAcknowledged())
        }
        
        guard routeHistory.count > 0 else {
            if nextRoute == .MailingLists {
                navigationController.pushViewController(mailingListViewController, animated: false)
            }
            
            return
        }
        
        let oldRoute = routeHistory.last!
        
        switch (oldRoute, nextRoute) {
        case (.MailingLists, .Threads):
            navigationController.pushViewController(threadsViewController, animated: true)
        case (.Threads, .ThreadDetail):
            threadDetailViewController = constructThreadDetailViewController()
            navigationController.pushViewController(threadDetailViewController, animated: true)
        default:
            break
        }
    }
}

extension AppCoordinator: ThreadsViewControllerDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Hmm... not totally sure about the abstraction of this.
        let selectedEmail = threadsTableViewDataSource?.emails[indexPath.row]
        mainStore.dispatch(SetSelectedThreadWithRootMessageID(rootMessageID: selectedEmail?.headers.messageID))
        mainStore.dispatch(MoveTo(route: .ThreadDetail))
    }
    
    func threadsViewControllerRequestsReloadedData() {
        if mainStore.state.selectedMailingList == .SwiftEvolution {
            mainStore.dispatch(SetMailingListIsRefreshing(mailingList: .SwiftEvolution, isRefreshing: true))
            mainStore.dispatch(RequestSwiftEvolution(MostRecentListPeriodForDate(), useCache: true))
        }
    }
    
    func threadsViewControllerDidNavigateBackwards(threadsViewController: ThreadsViewController) {
        mainStore.dispatch(SetSelectedMailingList(list: nil))
        mainStore.dispatch(MoveTo(route: .MailingLists))
    }
}

extension AppCoordinator: ThreadDetailViewControllerDelegate {
    func threadDetailViewControllerDidNavigateBackwards(threadDetailViewController: ThreadDetailViewController) {
        // Need to work around the fact that we can't override UINavigationController's back button action.
        // We need to reconcile the UI route (currently at .Threads) with the route history (which is currently ending at .ThreadDetail)
        mainStore.dispatch(SetSelectedThreadWithRootMessageID(rootMessageID: nil))
        mainStore.dispatch(MoveTo(route: .Threads))
    }
}

extension AppCoordinator: MailingListViewControllerDelegate {
    func mailingListViewControllerDidSelectMailingList(mailingList: MailingListType) {
        mainStore.dispatch(SetSelectedMailingList(list: MailingList(rawValue: mailingList)))
        mainStore.dispatch(MoveTo(route: .Threads))
    }
}
