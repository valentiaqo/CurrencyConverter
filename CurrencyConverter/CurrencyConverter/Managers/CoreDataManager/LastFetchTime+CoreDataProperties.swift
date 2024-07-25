//
//  LastFetchTime+CoreDataProperties.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 24/07/2024.
//
//

import Foundation
import CoreData


extension LastFetchTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LastFetchTime> {
        return NSFetchRequest<LastFetchTime>(entityName: "LastFetchTime")
    }

    @NSManaged public var fetchDate: Date?

}

extension LastFetchTime : Identifiable {

}
