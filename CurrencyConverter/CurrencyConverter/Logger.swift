//
//  Logger.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 21/07/2024.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let networkManager = Logger(subsystem: subsystem, category: "networkmanager")
    static let coreDataManager = Logger(subsystem: subsystem, category: "coredatamanager")
}

