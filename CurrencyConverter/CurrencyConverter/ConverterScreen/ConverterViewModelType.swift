//
//  ConverterViewModelType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import RxSwift
import XCoordinator

protocol ConverterViewModelType: AnyObject {
    var router: WeakRouter<UserListRoute> { get }
    var currencyNetworkManager: CurrencyNetworkManagerType { get }
    
    var selectedCurrencies: BehaviorSubject<[SectionOfCurrency]> { get }
    
    var selectedTradingOption: TradingOption { get set }
    var currencyRates: CurrencyRates? { get }
    var currentlyEditedCurrency: Currency? { get set }
    
    var disposeBag: DisposeBag { get }
    
    func addCurrencyButtonPressed()
    func rearrangeCurrencyPosition(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
    func deleteCurrency(at indexPath: IndexPath)
    func fetchCurrencyRates()
    func getCurrencyRate(for cell: SelectedCurrencyCell, basedOn baseCell: SelectedCurrencyCell) -> Double
    func performCurrencyConversion(conversionOption: ConversionOption, baseRate: (ask: Double, bid: Double)?, convertedRate: (ask: Double, bid: Double)?, convertedValue: Double) -> Double
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType
}
