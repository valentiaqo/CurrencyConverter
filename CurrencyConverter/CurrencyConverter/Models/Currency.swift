//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 21/01/2024.
//

import Foundation

enum Currency: String, CaseIterable {
    case usd
    case eur
    case pln
    
    var code: String {
        rawValue.uppercased()
    }
}
