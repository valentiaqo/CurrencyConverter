//
//  SelectedCurrencies+CoreDataProperties.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 21/07/2024.
//
//

import Foundation
import CoreData


extension SelectedCurrencies {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SelectedCurrencies> {
        return NSFetchRequest<SelectedCurrencies>(entityName: "SelectedCurrencies")
    }

    @NSManaged public var chosenCurrency: String?

}

extension SelectedCurrencies : Identifiable {

}
