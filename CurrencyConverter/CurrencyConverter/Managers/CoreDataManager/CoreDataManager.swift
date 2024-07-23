//
//  CoreDataManager.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 20/07/2024.
//

import UIKit
import CoreData
import OSLog

final class CoreDataManager: CoreDataManagerType {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchSelectedCurrencies() -> [Currency] {
        do {
            let selectedCurrencies = try context.fetch(SelectedCurrencies.fetchRequest())
            let chosenCurrencies = selectedCurrencies.compactMap { $0.chosenCurrency }
            let finalCurrencies = chosenCurrencies.compactMap { Currency.getCurrency(basedOn: $0) }
            
            return finalCurrencies
        } catch {
            Logger.coreDataManager.error("Failed to fetch SelectedCurrencies: \(error.localizedDescription)")
            return []
        }
    }
    
    func addSelectedCurrency(currencyName: String) {
        let currencyToAdd = SelectedCurrencies(context: context)
        currencyToAdd.chosenCurrency = currencyName
        do {
            try context.save()
        } catch {
            Logger.coreDataManager.error("Failed to add SelectedCurrencies: \(error.localizedDescription)")
        }
    }
    
    func deleteSelectedCurrency(currencyName: String) {
        do {
            let selectedCurrencies = try context.fetch(SelectedCurrencies.fetchRequest())
            selectedCurrencies.forEach { selectedCurrency in
                if selectedCurrency.chosenCurrency == currencyName {
                    context.delete(selectedCurrency)
                }
            }
            try context.save()
        } catch {
            Logger.coreDataManager.error("Failed to remove SelectedCurrencies: \(error.localizedDescription)")
        }
        
    }
    
}
