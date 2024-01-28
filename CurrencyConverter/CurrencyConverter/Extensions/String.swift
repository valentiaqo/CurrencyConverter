//
//  String.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 25/01/2024.
//

import Foundation

extension String {
    /// Truncates the string to a specified maximum length, if the string's length exceeds the specified limit.
    func truncated(to length: Int) -> String {
        if self.count > length {
            let truncatedIndex = self.index(self.startIndex, offsetBy: length)
            return String(self[..<truncatedIndex])
        }
        return self
    }
    
    func withoutLastCharacter() -> String {
        guard !self.isEmpty else {
            return self
        }
        
        let endIndex = self.index(before: self.endIndex)
        return String(self[..<endIndex])
    }
}
