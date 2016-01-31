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

/*
- This is email 1
- This is 1 child of email 1
- This is 2 child of email 1
- This is 1 child of email 1, 2
- This is 2 child of email 1, 2
- This is email 2
- This is 1 child of email 2
*/

struct TestEmail {
    let text: String
    let children: [TestEmail]
}

let email0 = TestEmail(text: "email 0", children: [email00, email01])
let email00 = TestEmail(text: "email00", children: [])
let email01 = TestEmail(text: "email01", children: [email010, email011])
let email010 = TestEmail(text: "email010", children: [])
let email011 = TestEmail(text: "email011", children: [])
let email1 = TestEmail(text: "email 1", children: [email10])
let email10 = TestEmail(text: "email10", children: [])


let rootEmails = [email0, email1]

class AccordionDataSource: DSNestedAccordionHandler {
    override func noOfRowsInRootLevel() -> Int {
        return rootEmails.count
    }
    
    override func tableView(view: UITableView!, noOfChildRowsForCellAtPath path: DSCellPath!) -> Int {
        return emailForTreePath(rootEmails, path: path).children.count
    }
    
    private func emailForTreePath(list: [TestEmail], path: DSCellPath) -> TestEmail {
        let route = path.levelIndexes.map { $0.integerValue! }
        var email: TestEmail?
        var childList: [TestEmail] = list
        
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
        let cell = view.dequeueReusableCellWithIdentifier("threadDetailCellIdentifier")!
        let email = emailForTreePath(rootEmails, path: path)
        cell.textLabel?.text = email.text
        return cell
    }
}

extension AccordionDataSource: ThreadDetailTableViewHandler {}

class AppCoordinator: NSObject, StoreSubscriber {
    let navigationController: UINavigationController
    
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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        super.init()
        
        mainStore.subscribe(self)
        mainStore.dispatch(MoveTo(route: .Threads))
    }
    
    func newState(state: AppState) {
        if let nextRoute = state.nextRoute {
            route(nextRoute, routeHistory: state.routeHistory)
        }
        
        if state.routeHistory.last == .ThreadDetail {
            threadDetailViewController.reload()
        }
        
        if state.emailList.count > 0 && state.rootEmailList.count == 0 {
            let forest = PartitionEmailsIntoTreeForest(state.emailList)
            mainStore.dispatch(SetRootEmailList(contents: forest.map { $0.email }))
            threadsViewController.relod()
        }
    }
    
    func route(nextRoute: Route, routeHistory: [Route]) {
        defer {
            mainStore.dispatch(NextRouteAcknowledged())
        }
        
        guard routeHistory.count > 0 else {
            if nextRoute == .Threads {
                navigationController.pushViewController(threadsViewController, animated: false)
            }
            
            return
        }
        
        let oldRoute = routeHistory.last!
        
        switch (oldRoute, nextRoute) {
        case (.Threads, .ThreadDetail):
            navigationController.pushViewController(threadDetailViewController, animated: true)
        case (.ThreadDetail, .Threads):
            // Deliberate no-op--see the comments in `threadDetailViewControllerDidNavigateBackwards`.
            break
        default:
            break
        }
    }
}

extension AppCoordinator: ThreadsViewControllerDelegate {
    func threadsViewControllerDidSelectRowAtIndexPath(indexPath: NSIndexPath) {
        mainStore.dispatch(MoveTo(route: .ThreadDetail))
    }
    
    func threadsViewControllerRequestsReloadedData() {
        mainStore.dispatch(RequestSwiftEvolution(ListPeriod(identifier: "2015-December")))
    }
}

extension AppCoordinator: ThreadDetailViewControllerDelegate {
    func threadDetailViewControllerDidNavigateBackwards(threadDetailViewController: ThreadDetailViewController) {
        // Need to work around the fact that we can't override UINavigationController's back button action.
        // We need to reconcile the UI route (currently at .Threads) with the route history (which is currently ending at .ThreadDetail)
        mainStore.dispatch(MoveTo(route: .Threads))
    }
}
