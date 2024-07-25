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
    
    func retrieveSelectedCurrencies() -> [Currency] {
        do {
            let fetchedCurrencies = try context.fetch(SelectedCurrencies.fetchRequest())
            let chosenCurrencies = fetchedCurrencies.compactMap { $0.chosenCurrency }
            let selectedCurrencies = chosenCurrencies.compactMap { Currency.getCurrency(basedOn: $0) }
            
            return selectedCurrencies
        } catch {
            Logger.coreDataManager.error("Failed to retrieve SelectedCurrencies: \(error.localizedDescription)")
            return []
        }
    }
    
    func createSelectedCurrency(currencyName: String) {
        let currencyToAdd = SelectedCurrencies(context: context)
        currencyToAdd.chosenCurrency = currencyName
        do {
            try context.save()
        } catch {
            Logger.coreDataManager.error("Failed to create SelectedCurrencies: \(error.localizedDescription)")
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
            Logger.coreDataManager.error("Failed to delete SelectedCurrencies: \(error.localizedDescription)")
        }
        
    }
    
    func retrieveCurrencyRatesCache() -> CurrencyRates? {
        do {
            let currencyRates = try context.fetch(CurrencyRatesCache.fetchRequest())
            let quotes = currencyRates.compactMap { currencyRatesCache in
                Quote(ask: currencyRatesCache.ask, bid: currencyRatesCache.bid, mid: nil, baseCurrency: "USD", quoteCurrency: currencyRatesCache.quoteCurrency)
            }
            
            if let currencyRates = CurrencyRates(currencyData: CurrencyData(quotes: quotes)) {
                return currencyRates
            } else {
                return nil
            }
        } catch {
            Logger.coreDataManager.error("Failed to retrieve CurrencyRatesCache: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createCurrencyRatesCache(rates: CurrencyRates) {
        deleteCurrencyRatesCache()
        
        rates.quotes.forEach { quote in
            guard let ask = quote.ask, let bid = quote.bid, let quoteCurrency = quote.quoteCurrency else { return }
            
            let quoteToAdd = CurrencyRatesCache(context: context)
            quoteToAdd.ask = ask
            quoteToAdd.bid = bid
            quoteToAdd.quoteCurrency = quoteCurrency
        }
        
        do {
            try context.save()
        } catch {
            Logger.coreDataManager.error("Failed to create CurrencyRatesCache: \(error.localizedDescription)")
        }
    }
    
    func deleteCurrencyRatesCache() {
        do {
            let currencyRates = try context.fetch(CurrencyRatesCache.fetchRequest())
            currencyRates.forEach { currencyRateCache in
                context.delete(currencyRateCache)
            }
            try context.save()
        } catch {
            Logger.coreDataManager.error("Failed to delete SelectedCurrencies: \(error.localizedDescription)")
        }
    }
    
    func retrieveLastFetchTime() -> Date? {
        do {
            let lastFetchTime = try context.fetch(LastFetchTime.fetchRequest())
            let fetchDate = lastFetchTime.first?.fetchDate
            return fetchDate
        } catch {
            Logger.coreDataManager.error("Failed to retrieve LastFetchTime: \(error.localizedDescription)")
           return nil
        }
    }
    
    func createLastFetchTime(currentFetchDate: Date) {
        deleteLastFetchTime()
        
        let dateToAdd = LastFetchTime(context: context)
        dateToAdd.fetchDate = currentFetchDate
        
        do {
            try context.save()
        } catch {
            Logger.coreDataManager.error("Failed to create LastFetchTime: \(error.localizedDescription)")
        }
    }
    
    func deleteLastFetchTime() {
        do {
            let lastFetchTime = try context.fetch(LastFetchTime.fetchRequest())
            lastFetchTime.forEach { lastFetchTime in
                context.delete(lastFetchTime)
            }
            
            try context.save()
        } catch {
            Logger.coreDataManager.error("Failed to delete LastFetchTime: \(error.localizedDescription)")
        }
    }
}
