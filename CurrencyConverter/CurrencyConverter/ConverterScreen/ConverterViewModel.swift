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
    let currencyNetworkManager: CurrencyNetworkManagerType = CurrencyNetworkManager()
    let selectedCurrencies: BehaviorSubject<[SectionOfCurrency]> = .init(value: [SectionOfCurrency(items: [.usd, .eur, .pln])])
    var selectedTradingOption: TradingOption = .bid
    var currencyRates: CurrencyRates?
    var editedCurrency: Currency?
    var currencyRatePairs: [Currency: String] = [:]
    
    let disposeBag = DisposeBag()
    
    init(router: WeakRouter<UserListRoute>) {
        self.router = router
        fetchCurrencyRates()
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
        newSelectedCurrencies.remove(at: indexPath.row)
        
        sectionOfCurrencies.items = newSelectedCurrencies
        selectedCurrencies.onNext([sectionOfCurrencies])
    }
    
    func fetchCurrencyRates() {
        Task {
            currencyRates = await currencyNetworkManager.fetchCurrentCurrenciesRates()
        }
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
        switch conversionOption {
        case .toUsd:
            guard let baseRate else { return Double() }
            if selectedTradingOption == .ask {
                return (1 / baseRate.ask) * convertedValue
            } else {
                return (1 / baseRate.bid) * convertedValue
            }
        case .toNonUsdBasedOnUsd:
            guard let convertedRate else { return Double() }
            if selectedTradingOption == .ask {
                return convertedRate.ask * convertedValue
            } else {
                return convertedRate.bid * convertedValue
            }
        case .toNonUsdBasedOnNonUsd:
            guard let baseRate, let convertedRate else { return Double() }
            if selectedTradingOption == .ask {
                return (1 / baseRate.ask) * convertedValue * convertedRate.ask
            } else {
                return (1 / baseRate.bid) * convertedValue * convertedRate.bid
            }
        }
    }
    
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType {
        return SelectedCurrencyCellViewModel(currency: currency)
    }
}
