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
    
    func fetchSelectedCurrencies() -> [Currency]
    func addSelectedCurrency(currencyName: String)
    func deleteSelectedCurrency(currencyName: String)
}
