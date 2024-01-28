//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 21/01/2024.
//

import Foundation
import Differentiator

enum Currency: String, CaseIterable {
    // LIST TO BE CHANGED
    case aed
    case aud
    case cad
    case chf
    case cny
    case czk
    case dkk
    case eur
    case gbp
    case ils
    case inr
    case jpy
    case krw
    case kzt
    case nok
    case pln
    case rub
    case sek
    case `try`
    case uah
    case usd
    case zar
    // LIST TO BE CHANGED
    
    var code: String {
        rawValue.uppercased()
    }
    
    var fullName: String {
        NSLocalizedString(code, comment: "Currency name")
    }
    
    static func allCurrenciesSorted() -> [SectionOfCurrency] {
        let alphabeticallySortedCurrenciesArray = Currency.allCases.sorted {
            $0.fullName < $1.fullName
        }
        var alphabeticallySorted2DArray = [SectionOfCurrency(items: [])]
        var section = 0
        for currency in alphabeticallySortedCurrenciesArray {
            if alphabeticallySorted2DArray[section].items.isEmpty || alphabeticallySorted2DArray[section].items.first?.fullName.first == currency.fullName.first {
                alphabeticallySorted2DArray[section].items.append(currency)
            } else {
                section += 1
                alphabeticallySorted2DArray.append(SectionOfCurrency(items: .init()))
                alphabeticallySorted2DArray[section].items.append(currency)
            }
        }
        return alphabeticallySorted2DArray
    }
}

struct SectionOfCurrency {
    var items: [Item]
}

extension SectionOfCurrency: SectionModelType {
    typealias Item = Currency
    
    init(original: SectionOfCurrency, items: [Item]) {
        self = original
        self.items = items
    }
}
