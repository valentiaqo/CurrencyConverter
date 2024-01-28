//
//  AvailableCurrencyCellViewModelType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import Foundation
import RxSwift

protocol AvailableCurrencyCellViewModelType: AnyObject {
    var currency: Observable<Currency> { get }
}
