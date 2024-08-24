//
//  BackgroundTaskManagerType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 04/08/2024.
//

import Foundation
import BackgroundTasks

protocol BackgroundTaskManagerType: AnyObject {
    static var taskId: String? { get }
    
    func taskRegistration()
    func handleTask(task: BGAppRefreshTask)
    func scheduleTask()
}
