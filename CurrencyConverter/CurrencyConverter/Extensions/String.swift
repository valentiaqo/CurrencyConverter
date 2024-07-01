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
    
    /// Removes the last character from a string and returns the modified string.
    func withoutLastCharacter() -> String {
        guard !self.isEmpty else {
            return self
        }
        
        let endIndex = self.index(before: self.endIndex)
        return String(self[..<endIndex])
    }
    
    /// Determines if a string conforms to a specific regex pattern. It compiles the provided regex pattern and attempts to find a match within the entire string. If a match is found, it returns `true`; otherwise, it returns `false`. If the provided regex pattern is invalid, this method will also return `false`.
    func isValidWith(regex: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        
        if regex.firstMatch(in: self, range: range) != nil {
            return true
        }
        
        return false
    }
    
    /// Converts current string to Double type, if possible
    func asDouble() -> Double? {
        guard let valueAsDouble = Double(self) else { return nil }
        return valueAsDouble
    }
}

extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? ""
    }
}
