//
//  BackgroundTaskManager.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 04/08/2024.
//

import Foundation
import OSLog
import BackgroundTasks

final class BackgroundTaskManager: NSObject, BackgroundTaskManagerType {
    let ratesNetworkManager: RatesNetworkManagerType = RatesNetworkManager(fetchType: .background)
    
    let taskId = "valentynponomarenko.CurrencyConverter.backgroundTask"
    var refreshTask: BGAppRefreshTask?
    
    // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"valentynponomarenko.CurrencyConverter.backgroundTask"]
    // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"valentynponomarenko.CurrencyConverter.backgroundTask"]
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRatesFetchCompleted(_:)), name: .ratesFetchCompleted, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleRatesFetchCompleted(_ notification: Notification) {
        guard let success = notification.userInfo?["success"] as? Bool else {
            refreshTask?.setTaskCompleted(success: false)
            Logger.backgroundTaskManager.error("Failed to find \"success\" notification")
            return
        }
        
        refreshTask?.setTaskCompleted(success: success)
    }
    
    func taskRegistration() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            guard let task = task as? BGAppRefreshTask else { return }
            self.handleTask(task: task)
        }
    }
    
    func handleTask(task: BGAppRefreshTask) {
        refreshTask = task
        
        task.expirationHandler = {
            self.ratesNetworkManager.urlSession.invalidateAndCancel()
            task.setTaskCompleted(success: false)
            Logger.backgroundTaskManager.error("Application time in the background expired")
        }
        
        Task {
            await ratesNetworkManager.fetchCurrentRates()
        }
        
        scheduleTask()
    }
    
    func scheduleTask() {
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            do {
                let newTask = BGAppRefreshTaskRequest(identifier: self.taskId)
                newTask.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
                try BGTaskScheduler.shared.submit(newTask)
            } catch {
                Logger.backgroundTaskManager.error("Failed to schedule a task: \(error.localizedDescription)")
            }
        }
    }
}

