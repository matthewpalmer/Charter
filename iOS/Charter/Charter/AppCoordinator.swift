//
//  AppCoordinator.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import RealmSwift

class AppCoordinator: NSObject {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        
        let mailingListsViewController = MailingListsViewController(mailingLists: MailingList.cases.map { $0.rawValue })
        mailingListsViewController.delegate = self
        self.navigationController.pushViewController(mailingListsViewController, animated: false)
    }
    
    // Caches
    private var threadsViewControllerForMailingList = [MailingList: ThreadsViewController]()
}

extension AppCoordinator: MailingListsViewControllerDelegate {
    func mailingListsViewControllerDidSelectMailingList(mailingList: MailingListType) {
        let viewController: ThreadsViewController
        let list = MailingList(rawValue: mailingList)!
        
        let cache = RealmDataSource()
        let network = EmailThreadNetworkDataSourceImpl()
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        
        if threadsViewControllerForMailingList[list] != nil {
            viewController = threadsViewControllerForMailingList[list]!
        } else {
            viewController = ThreadsViewController(emailThreadService: service, mailingList: mailingList)
            viewController.delegate = self
            threadsViewControllerForMailingList[list] = viewController
        }
        
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension AppCoordinator: ThreadsViewControllerDelegate {
    func threadsViewController(threadsViewController: ThreadsViewController, didSelectEmail email: Email) {        
        let cache = RealmDataSource()
        let network = EmailThreadNetworkDataSourceImpl()
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        let viewController = ThreadDetailViewController(service: service, rootEmail: email)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
