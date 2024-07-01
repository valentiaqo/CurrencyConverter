//
//  CurrencyNetworkManager.swift
//  CurrencyConverter
//
//  Created by Valentyn Ponomarenko on 12/02/2024.
//

import Foundation

final class CurrencyNetworkManager: CurrencyNetworkManagerType {
    static let APIKey = ProcessInfo.processInfo.environment["API_KEY"]
    static let URLString = "https://marketdata.tradermade.com/api/v1/live?currency=USDAED,USDAOA,USDARS,USDAUD,USDBGN,USDBHD,USDBRL,USDCAD,USDCHF,USDCLP,USDCNY,USDCNH,USDCOP,USDCZK,USDDKK,USDEUR,USDGBP,USDHKD,USDHRK,USDHUF,USDIDR,USDILS,USDINR,USDISK,USDJPY,USDKRW,USDKWD,USDMAD,USDMXN,USDMYR,USDNGN,USDNOK,USDNZD,USDOMR,USDPEN,USDPHP,USDPLN,USDRON,USDRUB,USDSAR,USDSEK,USDSGD,USDTHB,USDTRY,USDTWD,USDVND,USDXAG,USDXAU,USDXPD,USDXPT,USDZAR&api_key=\(APIKey ?? String())"
        
    func fetchCurrentCurrenciesRates() async -> CurrencyRates? {
        let data = await fetchData(withURLString: CurrencyNetworkManager.URLString)
        guard let currentRates = parseJSON(withData: data) else { return nil }
        return currentRates
    }
    
    func fetchData(withURLString URLString: String) async -> Data {
        guard let URL = URL(string: URLString) else { fatalError("Invalid URL") }
        do {
            let (data, _) = try await URLSession.shared.data(from: URL)
            return data
        } catch {
            fatalError("Error fetching data: \(error)")
        }
    }
    
    func parseJSON(withData data: Data) -> CurrencyRates? {
        do {
            let currencyData = try JSONDecoder().decode(CurrencyData.self, from: data)
            return CurrencyRates(currencyData: currencyData)
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
}
