//
//  SelectedCurrencyCellViewModel.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 15/01/2024.
//

import Foundation
import RxSwift

final class SelectedCurrencyCellViewModel: SelectedCurrencyCellViewModelType {
    let currency: Observable<Currency>
    
    init(currency: Currency) {
        self.currency = .just(currency)
    }
}
