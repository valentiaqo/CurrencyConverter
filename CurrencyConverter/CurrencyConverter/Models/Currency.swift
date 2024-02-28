//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 21/01/2024.
//

import Foundation
import Differentiator

enum Currency: String, CaseIterable {
    case aed
    case aoa
    case ars
    case aud
    case bgn
    case bhd
    case brl
    case cad
    case chf
    case clp
    case cny
    case cnh
    case cop
    case czk
    case dkk
    case eur
    case gbp
    case hkd
    case hrk
    case huf
    case idr
    case ils
    case inr
    case isk
    case jpy
    case krw
    case kwd
    case mad
    case mxn
    case myr
    case ngn
    case nok
    case nzd
    case omr
    case pen
    case php
    case pln
    case ron
    case rub
    case sar
    case sek
    case sgd
    case thb
    case `try`
    case twd
    case usd
    case vnd
    case xag
    case xau
    case xpd
    case xpt
    case zar
    
    var code: String {
        rawValue.uppercased()
    }
    
    var fullName: String {
        NSLocalizedString(code, comment: "Currency name")
    }
    
    static func sortedCurrencies(currencies: [Currency] = Currency.allCases) -> [SectionOfCurrency] {
        let alphabeticallySortedCurrenciesArray = currencies.sorted {
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
    
    static func getCurrency(basedOn currencyFullName: String) -> Currency? {
        return allCases.first { $0.code.lowercased().hasPrefix(currencyFullName.prefix(3).lowercased()) }
    }
    
    static func getNewCurrencyList(basedOn currentCurrencies: [Currency]) -> [SectionOfCurrency]  {
        let currenciesExceptSelected = allCases.filter { !currentCurrencies.contains($0) }
        return sortedCurrencies(currencies: currenciesExceptSelected)
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

