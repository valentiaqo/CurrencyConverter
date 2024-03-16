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

final class ConverterViewModel: ConverterViewModelType {
    let router: WeakRouter<UserListRoute>
    
    var selectedTradingOption: TradingOption = .bid
    let selectedCurrencies: BehaviorSubject<[SectionOfCurrency]> = .init(value: [SectionOfCurrency(items: [.usd, .eur, .pln])])
    
    //    fetchCurrentCurrenciesRates()
    
    init(router: WeakRouter<UserListRoute>) {
        self.router = router
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
    
    func cellViewModel(currency: Currency) -> SelectedCurrencyCellViewModelType {
        return SelectedCurrencyCellViewModel(currency: currency)
    }
}
