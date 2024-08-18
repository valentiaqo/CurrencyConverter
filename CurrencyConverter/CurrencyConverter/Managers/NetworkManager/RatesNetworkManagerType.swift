//
//  CurrencyNetworkManagerType.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 15/02/2024.
//

import Foundation

protocol RatesNetworkManagerType: AnyObject {
    var coreDataManager: CoreDataManagerType { get }
    static var APIKey: String? { get }
    static var URLString: String { get }
    var urlSession: URLSession { get }

    func fetchCurrentRates() async
    func parseJSON(withData data: Data) -> CurrencyRates?
}
