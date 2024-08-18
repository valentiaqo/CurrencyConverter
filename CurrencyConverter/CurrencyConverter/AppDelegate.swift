//
//  AppDelegate.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import CoreData
import OSLog
import BackgroundTasks

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private let backgroundTaskManager: BackgroundTaskManagerType = BackgroundTaskManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        backgroundTaskManager.taskRegistration()
        
        return true
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                Logger.coreDataManager.error("Failed to load persistent stores: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                Logger.coreDataManager.error("Failed to save context: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
