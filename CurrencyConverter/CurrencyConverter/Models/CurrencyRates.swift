//
//  CurrencyRates.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 12/02/2024.
//

import Foundation

struct CurrencyRates {
    let quotes: [Quote]
    
    init?(currencyData: CurrencyData) {
        self.quotes = currencyData.quotes
    }
}
