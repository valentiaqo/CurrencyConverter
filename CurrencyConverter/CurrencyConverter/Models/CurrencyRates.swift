//
//  CurrencyRates.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 12/02/2024.
//

import Foundation

struct CurrencyRates {
    let quotes: [Quote]
    
    func getRates(for currency: String) -> (ask: Double, bid: Double)? {
        for quote in quotes {
            if currency == quote.quoteCurrency {
                guard let ask = quote.ask, let bid = quote.bid else { return nil }
                return (ask, bid)
            }
        }
        return nil
    }
    
    init?(currencyData: CurrencyData) {
        self.quotes = currencyData.quotes
    }
}
