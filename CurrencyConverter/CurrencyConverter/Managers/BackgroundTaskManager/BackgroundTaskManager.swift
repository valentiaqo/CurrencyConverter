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
    let ratesNetworkManager: RatesNetworkManagerType = RatesNetworkManager()
    let coreDataManager: CoreDataManagerType = CoreDataManager()
    
    static let taskId = ProcessInfo.processInfo.environment["BG_TASK_IDENTIFIER"]
    var refreshTask: BGAppRefreshTask?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRatesFetchCompleted(_:)), name: .ratesFetchCompleted, object: nil)
        ratesNetworkManager.urlSession = URLSession(configuration: URLSessionConfiguration.background(withIdentifier: BackgroundTaskManager.taskId.orEmpty), delegate: self, delegateQueue: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleRatesFetchCompleted(_ notification: Notification) {
        refreshTask?.setTaskCompleted(success: true)
    }
    
    func taskRegistration() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundTaskManager.taskId.orEmpty, using: nil) { task in
            guard let task = task as? BGAppRefreshTask else { return }
            self.handleTask(task: task)
        }
    }
    
    func handleTask(task: BGAppRefreshTask) {
        refreshTask = task
        
        task.expirationHandler = {
            self.ratesNetworkManager.urlSession.invalidateAndCancel()
            task.setTaskCompleted(success: false)
            Logger.backgroundTaskManager.error("Application time in the background has expired")
        }
        
        ratesNetworkManager.fetchCurrentRatesBackground()
        
        scheduleTask()
    }
    
    func scheduleTask() {
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            do {
                let newTask = BGAppRefreshTaskRequest(identifier: BackgroundTaskManager.taskId.orEmpty)
                newTask.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
                try BGTaskScheduler.shared.submit(newTask)
            } catch {
                Logger.backgroundTaskManager.error("Failed to schedule a task: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - URLSessionDataTask
extension BackgroundTaskManager: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let currentRates = ratesNetworkManager.parseJSON(withData: data) else { return }
        
        DispatchQueue.main.async {
            self.coreDataManager.createCurrencyRatesCache(rates: currentRates)
            self.coreDataManager.createLastFetchTime(currentFetchDate: Date())
            NotificationCenter.default.post(name: .ratesFetchCompleted, object: nil)
        }
    }
}

