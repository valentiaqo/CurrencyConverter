//
//  AccountingNumberFormatter.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 10/02/2024.
//

import UIKit

final class AccountingNumberFormatter: NumberFormatter {
    private var maxFormattedTextLength = 20
    
    override init() {
        super.init()
        numberStyle = .decimal
        maximumFractionDigits = 2
        roundingMode = .down
        groupingSeparator = CharacterConstants.dot
        decimalSeparator = CharacterConstants.comma
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyTextFieldTextFormat(for textField: UITextField, previousText: String, currentText: String) -> String {
        let formatter = AccountingNumberFormatter()
        
        if textField.isFirstResponder {
            formatter.usesGroupingSeparator = false
            maxFormattedTextLength = 15
        }
        
        let newTextWithoutGroupingSeparators = currentText.replacingOccurrences(of: formatter.groupingSeparator, with: String())
        guard let newTextLast = currentText.last else { return currentText }
        
        let underCurrentDecimalLimit = currentText.components(separatedBy: formatter.decimalSeparator).count < 3
        let underPreviousDecimalLimit = previousText.components(separatedBy: formatter.decimalSeparator).count < 2
        let isLastCharacterDecimal = String(newTextLast) == formatter.decimalSeparator
        
        if !previousText.isEmpty && isLastCharacterDecimal && underCurrentDecimalLimit && underPreviousDecimalLimit {
            return currentText
        }
        
        if let numberWithoutGroupingSeparator = formatter.number(from: newTextWithoutGroupingSeparators),
           let formattedText = formatter.string(from: numberWithoutGroupingSeparator), formattedText.count <= maxFormattedTextLength {
                  
            if newTextWithoutGroupingSeparators.isValidWith(regex: RegexPattern.exactZero(separator: formatter.decimalSeparator)) {
                return formattedText + formatter.decimalSeparator + String(0)
            } else if newTextWithoutGroupingSeparators.isValidWith(regex: RegexPattern.twoOrThreeZeros(separator: formatter.decimalSeparator)) {
                return formattedText + formatter.decimalSeparator + String(0) + String(0)
            } else if newTextWithoutGroupingSeparators.isValidWith(regex: RegexPattern.zeroAtEnd(separator: formatter.decimalSeparator)) {
                return formattedText + String(0)
            } else  {
                return formattedText
            }
        }
        return currentText.isEmpty ? currentText : previousText
    }
    
    func textWithourGroupingSeparators(_ string: String) -> String {
        let formatter = AccountingNumberFormatter()
        return string.replacingOccurrences(of: formatter.groupingSeparator, with: String())
    }
}
