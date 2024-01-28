//
//  CurrencySelectionViewModelType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import Foundation
import RxRelay

protocol CurrencySelectionViewModelType: AnyObject {
    var availableCurrencies: [SectionOfCurrency] { get }
    var filteredCurrencies: BehaviorRelay<[SectionOfCurrency]> { get set }
    
    func updateFilteredCurrenciesWithSearchText(_ searchText: String)
    func cellViewModel(currency: Currency) -> AvailableCurrencyCellViewModelType
}
