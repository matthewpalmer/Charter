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
            let dataSource = ThreadsViewControllerDataSourceImpl(service: service, mailingList: mailingList, labelService: LabelServiceImpl())
            viewController = ThreadsViewController(dataSource: dataSource)
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
        let dataSource = ThreadDetailDataSourceImpl(service: service, rootEmail: email, codeBlockParser: SwiftCodeBlockParser())
        let viewController = ThreadDetailViewController(dataSource: dataSource)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func threadsViewController(threadsViewController: ThreadsViewController, didSearchWithPhrase phrase: String, inMailingList mailingList: MailingListType) {
        let cache = RealmDataSource()
        let network = EmailThreadNetworkDataSourceImpl()
        let service = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        let dataSource = ThreadsSearchViewControllerDataSource(service: service, labelService: LabelServiceImpl(), mailingList: mailingList, searchPhrase: phrase)
        
        let viewController = ThreadsViewController(dataSource: dataSource)
        viewController.searchEnabled = false
        viewController.refreshEnabled = false
        viewController.delegate = self
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
