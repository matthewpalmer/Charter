//
//  AppDelegate.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator!
    let navigationController = UINavigationController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        let orange = UIColor(red:0.99, green:0.43, blue:0.22, alpha:1)
        UINavigationBar.appearance().tintColor = orange
        UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = orange
        
        coordinator = AppCoordinator(navigationController: navigationController)
        
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                print("Migrating from realm schema 0")
                migration.deleteData(Email.className())
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        print("Realm database at \(Realm.Configuration.defaultConfiguration.path)")
        
        if NSUserDefaults.standardUserDefaults().boolForKey("FASTLANE_SNAPSHOT") {
            // If we are doing UI testing, load some stub data into the default Realm.
            // We can't do this from the UI test because the Realms will be different.
            // Runtime check that we are in snapshot mode.
            
            let realm = try! Realm()

            do {
                let fileURL = NSBundle.mainBundle().URLForResource("ScreenshotData", withExtension: "json")!
                let data = NSData(contentsOfURL: fileURL)!
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
                let emailDicts = ((json["_embedded"]! as! NSDictionary)["rh:doc"] as! Array<NSDictionary>)
                
                emailDicts.forEach {
                    let networkEmail = try! NetworkEmail(fromDictionary: $0)
                    try! Email.createFromNetworkEmail(networkEmail, inRealm: realm)
                }
            } catch let e {
                print(e)
                fatalError("Creating emails in realm failed")
            }
        }
        
        return true
    }
}

