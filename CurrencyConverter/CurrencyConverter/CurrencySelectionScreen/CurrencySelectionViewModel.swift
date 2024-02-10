//
//  CurrencySelectionViewModel.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import Foundation
import RxRelay

final class CurrencySelectionViewModel: CurrencySelectionViewModelType {
    let availableCurrencies: [SectionOfCurrency] = Currency.allCurrenciesSorted()
    var filteredCurrencies: BehaviorRelay<[SectionOfCurrency]>
    
    init() {
        self.filteredCurrencies = .init(value: availableCurrencies)
    }
    
    func updateFilteredCurrenciesWithSearchText(_ searchText: String) {
        let searchTextLowercased = searchText.lowercased()
        
        let currenciesFilteredWithSearchedText: [SectionOfCurrency.Item] = availableCurrencies
            .flatMap { $0.items }
            .filter { $0.fullName.lowercased().contains(searchTextLowercased) || $0.code.lowercased().contains(searchTextLowercased) }
        
        var alphabeticallySorted2DArray = [SectionOfCurrency(items: [])]
        var section = 0
        for currency in currenciesFilteredWithSearchedText {
            if alphabeticallySorted2DArray[section].items.isEmpty || alphabeticallySorted2DArray[section].items.first?.fullName.first == currency.fullName.first {
                alphabeticallySorted2DArray[section].items.append(currency)
            } else {
                section += 1
                alphabeticallySorted2DArray.append(SectionOfCurrency(items: .init()))
                alphabeticallySorted2DArray[section].items.append(currency)
            }
        }
        
        filteredCurrencies.accept(alphabeticallySorted2DArray)
    }
    
    func cellViewModel(currency: Currency) -> AvailableCurrencyCellViewModelType {
        return AvailableCurrencyCellViewModel(currency: currency)
    }
}
