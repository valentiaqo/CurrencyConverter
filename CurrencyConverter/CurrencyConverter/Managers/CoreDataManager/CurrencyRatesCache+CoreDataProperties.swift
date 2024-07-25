//
//  CurrencyRatesCache+CoreDataProperties.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 24/07/2024.
//
//

import Foundation
import CoreData


extension CurrencyRatesCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyRatesCache> {
        return NSFetchRequest<CurrencyRatesCache>(entityName: "CurrencyRatesCache")
    }

    @NSManaged public var ask: Double
    @NSManaged public var bid: Double
    @NSManaged public var quoteCurrency: String?

}

extension CurrencyRatesCache : Identifiable {

}
