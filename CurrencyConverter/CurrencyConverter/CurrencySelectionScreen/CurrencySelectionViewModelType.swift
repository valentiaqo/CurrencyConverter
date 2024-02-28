//
//  CurrencySelectionViewModelType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import Foundation
import RxRelay
import XCoordinator

protocol CurrencySelectionViewModelType: AnyObject {
    var router: WeakRouter<UserListRoute> { get }
    var availableCurrencies: [SectionOfCurrency] { get }
    var filteredCurrencies: BehaviorRelay<[SectionOfCurrency]> { get set }
    
    func updateFilteredCurrenciesWithSearchText(_ searchText: String)
    func cellViewModel(currency: Currency) -> AvailableCurrencyCellViewModelType
}
