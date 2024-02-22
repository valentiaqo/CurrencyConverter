//
//  CurrencyData.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 12/02/2024.
//

import Foundation

// MARK: - CurrencyData
struct CurrencyData: Codable {
    let endpoint: String
    let quotes: [Quote]
    let requestedTime: String
    let timestamp: Int

    enum CodingKeys: String, CodingKey {
        case endpoint, quotes, timestamp
        case requestedTime = "requested_time"
    }
}

// MARK: - Quote
struct Quote: Codable {
    let ask: Double?
    let baseCurrency: String?
    let bid, mid: Double?
    let quoteCurrency: String?

    enum CodingKeys: String, CodingKey {
        case ask, bid, mid
        case baseCurrency = "base_currency"
        case quoteCurrency = "quote_currency"
    }
}
