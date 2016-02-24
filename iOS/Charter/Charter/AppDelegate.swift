//
//  AppDelegate.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import ReSwift
import MailingListParser
import RealmSwift

let mainStore = Store(reducer: AppReducer(), state: AppState())

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator!
    let navigationController = UINavigationController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
//        coordinator = AppCoordinator(navigationController: navigationController)
        
        UINavigationBar.appearance().tintColor = UIColor(red:0.99, green:0.43, blue:0.22, alpha:1)
        
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                print("Migrating from realm schema 0")
                migration.deleteData(Email.className())
            }
            })
        
        Realm.Configuration.defaultConfiguration = config
        
        print("Realm database at \(Realm.Configuration.defaultConfiguration.path)")
        
        let realm = try! Realm()
        let cache = RealmDataSource(realm: realm)
        let network = EmailThreadNetworkDataSourceImpl(realm: realm)
        let emailService: EmailThreadService = EmailThreadServiceImpl(cacheDataSource: cache, networkDataSource: network)
        
        let request = EmailThreadRequestBuilder()
        request.mailingList = "swift-evolution"
        request.inReplyTo = Either.Right(NSNull())
        request.page = 1
        request.pageSize = 50
        request.sort = [("date", false)]
        request.onlyComplete = true
        
        emailService.getUncachedThreads(request.build()) { (emails) -> Void in
            print(emails)
        }
//        emailService.getCachedThreads(request.build()) { (emails) -> Void in
//            print(emails.map { $0.date })
//        }
        
        return true
    }
}

