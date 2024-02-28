//
//  ConverterViewModelType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import RxRelay
import XCoordinator

protocol ConverterViewModelType: AnyObject {
    var router: WeakRouter<UserListRoute> { get }
    var selectedTradingOption: TradingOption { get set }
    var selectedCurrencies: BehaviorRelay<[Currency]> { get }
    
    func addCurrencyButtonPressed()
    func rearrangeDraggedCurrencyPosition(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
    func deleteCurrency(at indexPath: IndexPath)
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType
}
