//
//  CurrencyNetworkManager.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 12/02/2024.
//

import Foundation
import OSLog

final class CurrencyNetworkManager: CurrencyNetworkManagerType {
    static let APIKey = ProcessInfo.processInfo.environment["API_KEY"]
    static let URLString = "https://marketdata.tradermade.com/api/v1/live?currency=USDAED,USDAOA,USDARS,USDAUD,USDBGN,USDBHD,USDBRL,USDCAD,USDCHF,USDCLP,USDCNY,USDCNH,USDCOP,USDCZK,USDDKK,USDEUR,USDGBP,USDHKD,USDHRK,USDHUF,USDIDR,USDILS,USDINR,USDISK,USDJPY,USDKRW,USDKWD,USDMAD,USDMXN,USDMYR,USDNGN,USDNOK,USDNZD,USDOMR,USDPEN,USDPHP,USDPLN,USDRON,USDRUB,USDSAR,USDSEK,USDSGD,USDTHB,USDTRY,USDTWD,USDVND,USDXAG,USDXAU,USDXPD,USDXPT,USDZAR&api_key=\(APIKey ?? String())"
    
    var cachedRates: CurrencyRates?
    var lastFetchTime: Date?
        
    func fetchCurrentCurrenciesRates() async -> CurrencyRates? {
        let currentTime = Date()
        if let lastFetchTime = lastFetchTime, currentTime.timeIntervalSince(lastFetchTime) < 3600 {
            return cachedRates
        }
        lastFetchTime = currentTime
        
        guard let data = await fetchData(withURLString: CurrencyNetworkManager.URLString), let currentRates = parseJSON(withData: data) else { return nil }
        cachedRates = currentRates
        
        return currentRates
    }
    
    func fetchData(withURLString URLString: String) async -> Data? {
        guard let URL = URL(string: URLString) else {
            Logger.networkManager.error("Failed to fetch data: invalid URL")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: URL)
            return data
        } catch {
            Logger.networkManager.error("Failed to fetch data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func parseJSON(withData data: Data) -> CurrencyRates? {
        do {
            let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
            return CurrencyRates(currencyData: currencyData)
        } catch {
            Logger.networkManager.error("Failed to parse JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
