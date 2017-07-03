//
//  AppDelegate.swift
//  Lynked
//
//  Created by Matthew Singleton on 12/11/16.
//  Copyright © 2016 Matthew Singleton. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import Fabric
import Branch
import Crashlytics
import Instabug

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // MARK: - NavBar Light Color
        UIApplication.shared.statusBarStyle = .lightContent
        
        // MARK: - Firebase/Fabric
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Fabric.with([Crashlytics.self, Branch.self])
        Branch.getInstance().initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
            guard error == nil else { return }
            guard let userDidClick = params?["+clicked_branch_link"] as? Bool else { return }
            if userDidClick {
                // This code will execute when your app is opened from a Branch deep link, which
                // means that you can route to a custom activity depending on what they clicked.
                // In this example, we'll just print out the data from the link that was clicked.
                debugPrint("deep link data:  \(String(describing: params))")
            }
        })
        
        
        // MARK: - Instabug
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            if let dic = NSDictionary(contentsOfFile: path) as? [String : String] {
                if let instaBugToken = dic["IBK"] {
                    Instabug.start(withToken: instaBugToken, invocationEvent: .shake)
                }
            }
        }
        
        
        // MARK: - App Run Counter for Review
        incrementAppRuns()
        
        return true
    }
    
    
     // Respond to URI scheme links
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // For Branch to detect when a URI scheme is clicked
        Branch.getInstance().handleDeepLink(url as URL!)
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // For Branch to detect when a Universal Link is clicked
        Branch.getInstance().continue(userActivity)
        return true
    }

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UserDefaults.standard.set(false, forKey: "unlocked")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UserDefaults.standard.set(false, forKey: "unlocked")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        UserDefaults.standard.set(false, forKey: "unlocked")
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Lynked")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


