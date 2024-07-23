//
//  CurrencyRateCache+CoreDataProperties.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 21/07/2024.
//
//

import Foundation
import CoreData


extension CurrencyRateCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyRateCache> {
        return NSFetchRequest<CurrencyRateCache>(entityName: "CurrencyRateCache")
    }

    @NSManaged public var lastFetchTime: Date?
    @NSManaged public var ask: Double
    @NSManaged public var bid: Double
    @NSManaged public var quoteCurrency: String?

}

extension CurrencyRateCache : Identifiable {

}
