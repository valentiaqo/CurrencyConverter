//
//  Coordinator.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 22/02/2024.
//

import Foundation
import XCoordinator

enum UserListRoute: Route {
    case converter
    case currencySelection([SectionOfCurrency])
}

final class UserListCoordinator: NavigationCoordinator<UserListRoute> {
    init() {
        super.init(initialRoute: .converter)
    }
    
    override func prepareTransition(for route: UserListRoute) -> NavigationTransition {
        switch route {
        case .converter:
            let viewModel = ConverterViewModel(router: weakRouter)
            let converterViewController = ConverterViewController(viewModel: viewModel)
            return .push(converterViewController)
            
        case .currencySelection (let currencies):
            let viewModel = CurrencySelectionViewModel(availableCurrencies: currencies, router: weakRouter)
            let currencySelectionViewController = CurrencySelectionViewController(viewModel: viewModel)
            return .push(currencySelectionViewController)
        }
    }
}
