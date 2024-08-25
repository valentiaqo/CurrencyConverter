//
//  Coordinator.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 22/02/2024.
//

import UIKit
import XCoordinator

enum UserListRoute: Route {
    case converter
    case currencySelection([SectionOfCurrency])
    case unwindToConverter(String)
}

final class UserListCoordinator: NavigationCoordinator<UserListRoute> {
    private let navigationController = UINavigationController()
    
    init() {
        super.init(rootViewController: navigationController, initialRoute: .converter)
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
            
        case .unwindToConverter (let currencyName):
            if let converterViewController = navigationController.viewControllers.first as? ConverterViewController {
                if let selectedCurrency = Currency.getCurrency(basedOn: currencyName),
                   var newSelectedCurrencies = try? converterViewController.viewModel.selectedCurrencies.value().first?.items {
                    newSelectedCurrencies.append(selectedCurrency)
                }
                
                converterViewController.viewModel.coreDataManager.createSelectedCurrency(currencyName: currencyName.truncated(to: 3).lowercased())
                converterViewController.viewModel.refreshSelectedCurrencies()
            }
            
            return .pop(animation: .default)
        }
    }
}
