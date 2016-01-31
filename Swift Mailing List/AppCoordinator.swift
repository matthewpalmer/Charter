//
//  AppCoordinator.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

class AppCoordinator: NSObject, StoreSubscriber {
    let navigationController: UINavigationController
    
    lazy var threadsViewController: ThreadsViewController = {
        let viewController = ThreadsViewController()
        viewController.delegate = self
        return viewController
    }()
    
    lazy var threadDetailViewController: ThreadDetailViewController = {
        let viewController = ThreadDetailViewController()
        viewController.dataSource = self
        return viewController
    }()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        super.init()
    }
    
    func newState(state: AppState) {
        if let nextRoute = state.nextRoute {
            route(nextRoute, routeHistory: state.routeHistory)
        }
        
        if state.routeHistory.last == .ThreadDetail {
            threadDetailViewController.reload()
        }
        
    }
    
    func route(nextRoute: Route, routeHistory: [Route]) {
        defer { mainStore.dispatch(NextRouteAcknowledged()) }
        
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
            navigationController.popToRootViewControllerAnimated(true)
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

extension AppCoordinator: ThreadDetailViewControllerDataSource {
    func threadDetailViewControllerEmailForIndexPath(threadDetailViewController: ThreadDetailViewController, indexPath: NSIndexPath) -> Email {
        return mainStore.state.emailList[indexPath.row]
    }
    
    func threadDetailViewControllerNumberOfEmailsInSection(threadDetailViewController: ThreadDetailViewController, section: Int) -> Int {
        return mainStore.state.emailList.count
    }
}
