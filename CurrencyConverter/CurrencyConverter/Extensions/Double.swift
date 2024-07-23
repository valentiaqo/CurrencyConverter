//
//  Double.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/07/2024.
//

import Foundation

extension Double {
    /// Truncates the double to two decimal places without rounding.
    func truncateToTwoDecimalPlaces() -> Double {
        return Double(floor(100 * self) / 100)
    }
}
