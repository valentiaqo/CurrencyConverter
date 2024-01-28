//
//  AvailableCurrencyCellViewModel.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import Foundation
import RxSwift

final class AvailableCurrencyCellViewModel: AvailableCurrencyCellViewModelType {
    let currency: Observable<Currency>
    
    init(currency: Currency) {
        self.currency = .just(currency)
    }
}
