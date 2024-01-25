//
//  SelectedCurrencyCellViewModelType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 15/01/2024.
//

import Foundation
import RxSwift

protocol SelectedCurrencyCellViewModelType: AnyObject {
    var currency: Observable<Currency> { get }
}
