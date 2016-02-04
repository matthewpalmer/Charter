//
//  AppCoordinator.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import ReSwift
import DSNestedAccordion

class AccordionDataSource: DSNestedAccordionHandler {
    var rootEmails: [EmailTreeNode] = []
    
    override func noOfRowsInRootLevel() -> Int {
        return rootEmails.count
    }
    
    override func tableView(view: UITableView!, noOfChildRowsForCellAtPath path: DSCellPath!) -> Int {
        return emailForTreePath(rootEmails, path: path).children.count
    }
    
    private func emailForTreePath(list: [EmailTreeNode], path: DSCellPath) -> EmailTreeNode {
        let route = path.levelIndexes.map { $0.integerValue! }
        var email: EmailTreeNode?
        var childList: [EmailTreeNode] = list
        
        for i in 0..<route.count {
            if i == route.count - 1 {
                // Last
                email = childList[route[i]]
            } else {
                email = childList[route[i]]
                childList = email!.children
            }
        }
        
        return email!
    }
    
    override func tableView(view: UITableView!, cellForPath path: DSCellPath!) -> UITableViewCell! {
        let cell = view.dequeueReusableCellWithIdentifier(ThreadDetailViewController.fullMessageCellIdentifier) as! FullEmailMessageTableViewCell
        
        let email = emailForTreePath(rootEmails, path: path).email
        
                cell.leadingMarginConstraint.constant = CGFloat(-10 * path.levelIndexes.count)
        
        cell.dateLabel.text = email.headers.date
        cell.subjectLabel.text = email.headers.subject
        cell.contentTextView.text = email.content
        
        return cell
    }
}

extension AccordionDataSource: ThreadDetailTableViewHandler {}

class ThreadsTableViewDataSource: NSObject, ThreadsViewControllerDataSource {
    private let emails: [Email]
    private let title: String
    
    // Conflicted about this data source taking in the entire app state
    init(state: AppState) {
        title = state.selectedMailingList!.rawValue.name
        
        self.emails = PartitionEmailsIntoTreeForest(
            state.emailList.filter { $0.mailingList == state.selectedMailingList! }
            ).map { $0.email }
    }
    
    deinit {
        print("deiinit")
    }
    
    private lazy var squareBracketRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^\\[.*\\]", options: .CaseInsensitive)
    }()
    
    private lazy var leadingSpaceRegex: NSRegularExpression = {
        return try! NSRegularExpression(pattern: "^\\s+", options: .CaseInsensitive)
    }()
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ThreadsViewController.reuseIdentifier, forIndexPath: indexPath)
        let subject = emails[indexPath.row].headers.subject
        let noSquareBrackets = squareBracketRegex.stringByReplacingMatchesInString(subject, options: [], range: NSMakeRange(0, subject.characters.count), withTemplate: "")
        let noLeadingSpaces = leadingSpaceRegex.stringByReplacingMatchesInString(noSquareBrackets, options: [], range: NSMakeRange(0, noSquareBrackets.characters.count), withTemplate: "")
        
        cell.textLabel?.text = noLeadingSpaces
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
    
    lazy var detailTableViewHandler: AccordionDataSource = {
        return AccordionDataSource()
    }()
    
    lazy var threadDetailViewController: ThreadDetailViewController = {
        let viewController = ThreadDetailViewController()
        viewController.handler = self.detailTableViewHandler
        viewController.delegate = self
        return viewController
    }()
    
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
            detailTableViewHandler.rootEmails = forest.filter { $0.email.headers.messageID == state.selectedThreadWithRootMessageID }
            detailTableViewHandler.reload()
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
            mainStore.dispatch(RequestSwiftEvolution(MostRecentListPeriodForDate(), useCache: false))
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
