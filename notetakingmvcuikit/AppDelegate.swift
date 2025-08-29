//
//  AppDelegate.swift
//  notetakingmvcuikit
//
//  Created by sachin kumar on 29/08/25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data Integration with MVC
    // Using our beautiful CoreDataManager instead of the default implementation
    // This demonstrates proper MVC architecture where the MODEL layer handles all data operations
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes in the application's managed object context when the application terminates.
        // Using our MVC Model layer (CoreDataManager) instead of AppDelegate directly
        CoreDataManager.shared.saveContext()
        print("💾 App terminating - Core Data saved via MVC Model layer")
    }
    
    // MARK: - Legacy Core Data Support (for reference)
    // Keeping the original Core Data stack for compatibility, but using our MVC CoreDataManager
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "notetakingmvcuikit")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        // Delegate to our MVC Model layer instead of handling Core Data directly
        CoreDataManager.shared.saveContext()
    }

}

