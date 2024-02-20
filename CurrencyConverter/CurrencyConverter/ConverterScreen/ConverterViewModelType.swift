//
//  ConverterViewModelType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import RxRelay

protocol ConverterViewModelType: AnyObject {
    var selectedTradingOption: TradingOption { get set }
    var selectedCurrencies: BehaviorRelay<[Currency]> { get }
//    var currencyAmount: Int? { get set }
//    
//    func convertCurrency(for cell: SelectedCurrencyCell, value: Double)
    
    func rearrangeDraggedCurrencyPosition(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
    func deleteCurrency(at indexPath: IndexPath)
    
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType
}
