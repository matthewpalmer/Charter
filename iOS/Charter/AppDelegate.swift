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
        
        coordinator = AppCoordinator(navigationController: navigationController)
        
        UINavigationBar.appearance().tintColor = UIColor(red:0.99, green:0.43, blue:0.22, alpha:1)
        
        print("Realm database at \(Realm.Configuration.defaultConfiguration.path)")
        
        return true
    }
}

