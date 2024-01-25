//
//  ConverterViewModelType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import Foundation
import RxRelay

protocol ConverterViewModelType: AnyObject {
    var selectedTradingOption: TradingOption { get set }
    var selectedCurrencies: BehaviorRelay<[Currency]> { get }
    
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType
}
