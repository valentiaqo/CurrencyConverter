//
//  CoreDataManagerType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 20/07/2024.
//

import Foundation
import CoreData

protocol CoreDataManagerType: AnyObject {
    var context: NSManagedObjectContext { get }
    
    func retrieveSelectedCurrencies() -> [Currency]
    func createSelectedCurrency(currencyName: String)
    func deleteSelectedCurrency(currencyName: String)
    func retrieveCurrencyRatesCache() -> CurrencyRates?
    func createCurrencyRatesCache(rates: CurrencyRates)
    func deleteCurrencyRatesCache()
    func retrieveLastFetchTime() -> Date?
    func createLastFetchTime(currentFetchDate: Date) 
    func deleteLastFetchTime()
}
