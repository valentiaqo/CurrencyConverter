//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import RxSwift
import RxRelay

enum TradingOption {
    case bid
    case ask
}

final class ConverterViewModel: ConverterViewModelType {
    var selectedTradingOption: TradingOption = .bid
    
    let selectedCurrencies: BehaviorRelay<[Currency]> = .init(value: [.usd, .eur, .pln])
    
    //    fetchCurrentCurrenciesRates()
    
    func rearrangeDraggedCurrencyPosition(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        if destinationIndexPath != sourceIndexPath {
            var rearrangedCurrencies = selectedCurrencies.value
            let movedCurrency = rearrangedCurrencies[sourceIndexPath.row]
            rearrangedCurrencies.remove(at: sourceIndexPath.row)
            rearrangedCurrencies.insert(movedCurrency, at: destinationIndexPath.row)
            selectedCurrencies.accept(rearrangedCurrencies)
        }
    }
    
    func deleteCurrency(at indexPath: IndexPath) {
        var newSelectedCurrencies = selectedCurrencies.value
        newSelectedCurrencies.remove(at: indexPath.row)
        
        selectedCurrencies.accept(newSelectedCurrencies)
    }
    
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType {
        return SelectedCurrencyCellViewModel(currency: currency)
    }
}
