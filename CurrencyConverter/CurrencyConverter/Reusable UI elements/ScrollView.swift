//
//  ScrollView.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 23/01/2024.
//

import UIKit

final class ScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        super.touchesShouldCancel(in: view)
        return true
    }
}
