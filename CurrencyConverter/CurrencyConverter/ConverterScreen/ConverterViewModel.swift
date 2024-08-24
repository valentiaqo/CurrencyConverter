//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 31/12/2023.
//

import UIKit
import RxSwift
import XCoordinator

enum TradingOption {
    case bid
    case ask
}

enum ConversionOption {
    case toUsd
    case toNonUsdBasedOnUsd
    case toNonUsdBasedOnNonUsd
}

final class ConverterViewModel: ConverterViewModelType {
    let router: WeakRouter<UserListRoute>
    let currencyNetworkManager: RatesNetworkManagerType = RatesNetworkManager()
    let coreDataManager: CoreDataManagerType = CoreDataManager()
    var selectedCurrencies: BehaviorSubject<[SectionOfCurrency]> = .init(value: [SectionOfCurrency(items: [.usd, .eur, .pln])])
    var selectedTradingOption: TradingOption = .bid
    var currencyRates: CurrencyRates?
    var editedCurrency: Currency?
    var currencyRatePairs: [Currency: String] = [:]
    
    let disposeBag = DisposeBag()
    
    init(router: WeakRouter<UserListRoute>) {
        self.router = router
        fetchCurrencyRates()
        refreshSelectedCurrencies()
    }
    
    func addCurrencyButtonPressed() {
        guard let currencyList = try? selectedCurrencies.value().first?.items as? [Currency] else { return }
        let newCurrencyList = Currency.getNewCurrencyList(basedOn: currencyList)
        router.trigger(.currencySelection(newCurrencyList))
    }
    
    func rearrangeCurrencyPosition(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        if destinationIndexPath != sourceIndexPath {
            guard var sectionOfCurrencies = try? selectedCurrencies.value().first else { return }
            var rearrangedCurrencies = sectionOfCurrencies.items
            let movedCurrency = rearrangedCurrencies.remove(at: sourceIndexPath.row)
            rearrangedCurrencies.insert(movedCurrency, at: destinationIndexPath.row)
            
            sectionOfCurrencies.items = rearrangedCurrencies
            selectedCurrencies.onNext([sectionOfCurrencies])
        }
    }
    
    func deleteCurrency(at indexPath: IndexPath) {
        guard var sectionOfCurrencies = try? selectedCurrencies.value().first else { return }
        var newSelectedCurrencies = sectionOfCurrencies.items
        let deletedCurrency = newSelectedCurrencies.remove(at: indexPath.row)
        
        currencyRatePairs[deletedCurrency] = String()
        coreDataManager.deleteSelectedCurrency(currencyName: deletedCurrency.code.lowercased())
        
        sectionOfCurrencies.items = newSelectedCurrencies
        selectedCurrencies.onNext([sectionOfCurrencies])
    }
    
    func fetchCurrencyRates() {
        if coreDataManager.retrieveLastFetchTime() == nil || Date().timeIntervalSince(coreDataManager.retrieveLastFetchTime() ?? Date()) > 3600 {
            Task {
                if let rates = await currencyNetworkManager.fetchCurrentRates() {
                    coreDataManager.createCurrencyRatesCache(rates: rates)
                    coreDataManager.createLastFetchTime(currentFetchDate: Date())
                }
                currencyRates = coreDataManager.retrieveCurrencyRatesCache()
            }
        } else {
            currencyRates = coreDataManager.retrieveCurrencyRatesCache()
        }
        
        NotificationCenter.default.post(name: .ratesFetchCompleted, object: nil)
    }
    
    func refreshSelectedCurrencies() {
        selectedCurrencies.onNext([SectionOfCurrency(items: coreDataManager.retrieveSelectedCurrencies())])
    }
    
    func convertRates(baseCurrency: Currency, baseValue: String) {
        let currenciesToConvert = (try? selectedCurrencies.value().first?.items)?.filter({ $0 != baseCurrency})
        guard let baseCurrencyValue = baseValue.asDouble() else { return }
    
        currenciesToConvert?.forEach({ convertedCurrency in
            if let editedCurrencyRate = currencyRates?.getRates(for: convertedCurrency.code) {
                if baseCurrency == .usd {
                    // Performing currency conversion for USD based on USD
                  currencyRatePairs[convertedCurrency] = String(performCurrencyConversion(conversionOption: .toNonUsdBasedOnUsd, convertedRate: editedCurrencyRate, convertedValue: baseCurrencyValue))
                } else {
                    // Performing currency conversion for non-USD based on non-USD
                    guard let baseCurrencyRate = currencyRates?.getRates(for: baseCurrency.code) else { return }
                    currencyRatePairs[convertedCurrency] = String(performCurrencyConversion(conversionOption: .toNonUsdBasedOnNonUsd, baseRate: baseCurrencyRate, convertedRate: editedCurrencyRate, convertedValue: baseCurrencyValue))
                }
            } else {
                // Performing currency conversion for non-USD to USD
                guard let baseCurrencyRate = currencyRates?.getRates(for: baseCurrency.code) else { return }
                currencyRatePairs[convertedCurrency] = String(performCurrencyConversion(conversionOption: .toUsd, baseRate: baseCurrencyRate, convertedValue: baseCurrencyValue))
            }
        })
    }
    
    func performCurrencyConversion(conversionOption: ConversionOption, baseRate: (ask: Double, bid: Double)? = nil, convertedRate: (ask: Double, bid: Double)? = nil, convertedValue: Double) -> Double {
        var resultValue: Double = 0
        
        switch conversionOption {
        case .toUsd:
            guard let baseRate else { return Double() }
            if selectedTradingOption == .ask {
                resultValue = (1 / baseRate.ask) * convertedValue
            } else {
                resultValue = (1 / baseRate.bid) * convertedValue
            }
        case .toNonUsdBasedOnUsd:
            guard let convertedRate else { return Double() }
            if selectedTradingOption == .ask {
                resultValue = convertedRate.ask * convertedValue
            } else {
                resultValue = convertedRate.bid * convertedValue
            }
        case .toNonUsdBasedOnNonUsd:
            guard let baseRate, let convertedRate else { return Double() }
            if selectedTradingOption == .ask {
                resultValue = (1 / baseRate.ask) * convertedValue * convertedRate.ask
            } else {
                resultValue = (1 / baseRate.bid) * convertedValue * convertedRate.bid
            }
        }
        
        return resultValue.truncateToTwoDecimalPlaces()
    }
    
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType {
        return SelectedCurrencyCellViewModel(currency: currency)
    }
}
