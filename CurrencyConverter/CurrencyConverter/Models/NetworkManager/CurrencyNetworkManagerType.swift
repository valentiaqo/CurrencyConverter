//
//  CurrencyNetworkManagerType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 15/02/2024.
//

import Foundation

protocol CurrencyNetworkManagerType: AnyObject {
    static var APIKey: String? { get }
    static var URLString: String { get }
    
    func fetchCurrentCurrenciesRates() async
    func fetchData(withURLString URLString: String) async -> Data
    func parseJSON(withData data: Data) -> CurrencyRates?
}
