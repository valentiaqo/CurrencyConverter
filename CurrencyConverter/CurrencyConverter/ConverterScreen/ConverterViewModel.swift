//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import Foundation
import RxSwift
import RxRelay

enum TradingOption {
    case bid
    case ask
}

final class ConverterViewModel: ConverterViewModelType {
    var selectedTradingOption: TradingOption = .bid
    
    // TO BE CHANGED
    let selectedCurrencies: BehaviorRelay<[Currency]> = .init(value: [.usd, .eur, .pln, .usd, .eur, .pln])
    // TO BE CHANGED
    
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType {
        return SelectedCurrencyCellViewModel(currency: currency)
    }
}
