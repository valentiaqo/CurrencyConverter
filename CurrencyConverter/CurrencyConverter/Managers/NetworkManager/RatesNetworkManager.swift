//
//  CurrencyNetworkManager.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 12/02/2024.
//

import Foundation
import OSLog

enum FetchExecutionType {
    case foreground
    case background
}

final class RatesNetworkManager: RatesNetworkManagerType {
    static let APIKey = ProcessInfo.processInfo.environment["API_KEY"]
    static let URLString = "https://marketdata.tradermade.com/api/v1/live?currency=USDAED,USDAOA,USDARS,USDAUD,USDBGN,USDBHD,USDBRL,USDCAD,USDCHF,USDCLP,USDCNY,USDCNH,USDCOP,USDCZK,USDDKK,USDEUR,USDGBP,USDHKD,USDHRK,USDHUF,USDIDR,USDILS,USDINR,USDISK,USDJPY,USDKRW,USDKWD,USDMAD,USDMXN,USDMYR,USDNGN,USDNOK,USDNZD,USDOMR,USDPEN,USDPHP,USDPLN,USDRON,USDRUB,USDSAR,USDSEK,USDSGD,USDTHB,USDTRY,USDTWD,USDVND,USDXAG,USDXAU,USDXPD,USDXPT,USDZAR&api_key=\(APIKey ?? String())"
    
    var urlSession = URLSession(configuration: .default)
    
    func fetchCurrentRates() async -> CurrencyRates? {
        guard let URL = URL(string: RatesNetworkManager.URLString) else {
            Logger.networkManager.error("Failed to fetch data: invalid URL")
            return nil
        }
        
        var currentRates: CurrencyRates?
        
        do {
            let (data, _) = try await urlSession.data(from: URL)
            currentRates = parseJSON(withData: data)
        } catch {
            currentRates = nil
            Logger.networkManager.error("Failed to fetch data: \(error.localizedDescription)")
        }
        
        return currentRates
    }
    
    func fetchCurrentRatesBackground() {
        guard let url = URL(string: RatesNetworkManager.URLString) else {
            Logger.networkManager.error("Failed to fetch data: invalid URL")
            return
        }
        
        let dataTask = urlSession.dataTask(with: url)
        dataTask.resume()
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
