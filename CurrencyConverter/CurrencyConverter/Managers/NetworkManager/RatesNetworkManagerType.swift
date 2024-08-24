//
//  CurrencyNetworkManagerType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 15/02/2024.
//

import Foundation

protocol RatesNetworkManagerType: AnyObject {
    static var APIKey: String? { get }
    static var URLString: String { get }
    var urlSession: URLSession { get set }

    func fetchCurrentRates() async -> CurrencyRates?
    func fetchCurrentRatesBackground()
    func parseJSON(withData data: Data) -> CurrencyRates?
}
