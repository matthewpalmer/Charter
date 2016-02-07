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
        
        // The server sometimes sends us ?utf-8? junk, and there's nothing we can do.
        let noJunk: String
        if withinParens.hasPrefix("=?utf-8?") {
            noJunk = ""
        } else {
            noJunk = withinParens
        }
        
        return noJunk
    }
    
    func dateStringToDate(date: String) -> NSDate? {
        return sourceDateFormatter.dateFromString(date)
    }
    
    func formatDate(date: NSDate) -> String {
        return destinationDateFormatter.stringFromDate(date)
    }
}

class ThreadsTableViewDataSource: NSObject, ThreadsViewControllerDataSource {
    private let title: String
    var emails: Results<Email>
    
    // Conflicted about this data source taking in the entire app state
    init(state: AppState) {
        title = state.selectedMailingList!.rawValue.name
        emails = state.emailList!
    }
    
    private lazy var emailFormatter: EmailFormatter = EmailFormatter()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ThreadsViewController.reuseIdentifier, forIndexPath: indexPath) as! MessagePreviewTableViewCell
        let email = emails[indexPath.row]
        
        cell.subjectLabel.text = emailFormatter.formatSubject(email.subject)
        cell.nameLabel.text = emailFormatter.formatName(email.from)
        cell.timeLabel.text = emailFormatter.formatDate(email.date)
        
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
    
    private var threadsViewControllerForMailingList: [MailingList: ThreadsViewController] = [MailingList: ThreadsViewController]()
    private var threadsDataSourceForViewController: [ThreadsViewController: ThreadsTableViewDataSource] = [ThreadsViewController: ThreadsTableViewDataSource]()
    
    func constructThreadsViewController() -> ThreadsViewController {
        let viewController = ThreadsViewController()
        viewController.delegate = self
        return viewController
    }
    
    lazy var threadsViewController: ThreadsViewController = {
        return self.constructThreadsViewController()
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
        
        if state.nextRoute == .ThreadDetail && state.emailThread != nil {
            detailTableViewDataSource.indentationAndEmail = state.emailThread!
            if threadDetailViewController.tableView != nil && state.emailThread != nil {
                threadDetailViewController.tableView.reloadData()
            }
        }
        
        if state.routeHistory.last == .Threads && state.emailList == nil && state.mailingListIsRefreshing[MailingList.SwiftEvolution] == false {
            mainStore.dispatch(RetrieveRootEmails(state.selectedMailingList!))
        }
        
        if state.routeHistory.last == .Threads && state.emailList != nil && state.selectedMailingList != nil {
            let dataSource: ThreadsTableViewDataSource
            if threadsDataSourceForViewController[threadsViewController] == nil {
                dataSource = ThreadsTableViewDataSource(state: state)
                threadsDataSourceForViewController[threadsViewController] = dataSource
            } else {
                dataSource = threadsDataSourceForViewController[threadsViewController]!
            }
            
            // Has to be set multiple times because the first time through the state's email list will still be pointing at the previous list's email list.
            // The second time the email list has the updated pointer.
            if state.emailList != nil {
                dataSource.emails = state.emailList!
            }
            
            // Needs to be set multiple times because it must be done after the table view has appeared. Table view must handle selective reloading.
            threadsViewController.dataSource = dataSource
            
            if state.mailingListIsRefreshing[state.selectedMailingList!] == true {
                threadsViewController.beginRefreshing()
            } else {
                threadsViewController.endRefreshing()
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
            let viewController: ThreadsViewController
            if threadsViewControllerForMailingList[mainStore.state.selectedMailingList!] != nil {
                viewController = threadsViewControllerForMailingList[mainStore.state.selectedMailingList!]!
            } else {
                viewController = constructThreadsViewController()
                threadsViewControllerForMailingList[mainStore.state.selectedMailingList!] = viewController
            }
            
            threadsViewController = viewController
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
        tableView.selectRowAtIndexPath(nil, animated: false, scrollPosition: UITableViewScrollPosition.Middle)
        guard let selectedEmail = threadsDataSourceForViewController[threadsViewController]?.emails[indexPath.row] else { return }
        mainStore.dispatch(ComputeAndSetThreadForEmail(selectedEmail))
        mainStore.dispatch(MoveTo(route: .ThreadDetail))
    }
    
    func threadsViewControllerRequestsInitialData() {
        mainStore.dispatch(RetrieveRootEmails(mainStore.state.selectedMailingList!))
    }
    
    func threadsViewControllerRequestsReloadedData() {
        mainStore.dispatch(SetMailingListIsRefreshing(mailingList: mainStore.state.selectedMailingList!, isRefreshing: true))
        mainStore.dispatch(DownloadData(MostRecentListPeriodForDate(), mailingList: mainStore.state.selectedMailingList!))
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
        mainStore.dispatch(SetEmailThread(thread: nil))
        mainStore.dispatch(MoveTo(route: .Threads))
    }
}

extension AppCoordinator: MailingListViewControllerDelegate {
    func mailingListViewControllerDidSelectMailingList(mailingList: MailingListType) {
        mainStore.dispatch(SetSelectedMailingList(list: MailingList(rawValue: mailingList)))
        mainStore.dispatch(MoveTo(route: .Threads))
    }
}
