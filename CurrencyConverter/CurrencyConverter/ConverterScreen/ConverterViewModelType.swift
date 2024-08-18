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
    var currencyNetworkManager: RatesNetworkManagerType { get }
    var coreDataManager: CoreDataManagerType { get }
    var selectedCurrencies: BehaviorSubject<[SectionOfCurrency]> { get }
    var selectedTradingOption: TradingOption { get set }
    var currencyRates: CurrencyRates? { get }
    var editedCurrency: Currency? { get set }
    var currencyRatePairs: [Currency: String] { get set }

    func addCurrencyButtonPressed()
    func rearrangeCurrencyPosition(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
    func deleteCurrency(at indexPath: IndexPath)
    func fetchCurrencyRates()
    func refreshSelectedCurrencies()
    func convertRates(baseCurrency: Currency, baseValue: String)
    func performCurrencyConversion(conversionOption: ConversionOption, baseRate: (ask: Double, bid: Double)?, convertedRate: (ask: Double, bid: Double)?, convertedValue: Double) -> Double
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType
}
