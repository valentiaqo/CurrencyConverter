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

final class RatesNetworkManager: NSObject, RatesNetworkManagerType {
    let coreDataManager: CoreDataManagerType = CoreDataManager()
    
    static let APIKey = ProcessInfo.processInfo.environment["API_KEY"]
    static let URLString = "https://marketdata.tradermade.com/api/v1/live?currency=USDAED,USDAOA,USDARS,USDAUD,USDBGN,USDBHD,USDBRL,USDCAD,USDCHF,USDCLP,USDCNY,USDCNH,USDCOP,USDCZK,USDDKK,USDEUR,USDGBP,USDHKD,USDHRK,USDHUF,USDIDR,USDILS,USDINR,USDISK,USDJPY,USDKRW,USDKWD,USDMAD,USDMXN,USDMYR,USDNGN,USDNOK,USDNZD,USDOMR,USDPEN,USDPHP,USDPLN,USDRON,USDRUB,USDSAR,USDSEK,USDSGD,USDTHB,USDTRY,USDTWD,USDVND,USDXAG,USDXAU,USDXPD,USDXPT,USDZAR&api_key=\(APIKey ?? String())"
    
    var urlSession = URLSession(configuration: .default)

    init(fetchType: FetchExecutionType = .foreground) {
        super.init()
        
        let configuration: URLSessionConfiguration
        if fetchType == .background {
            configuration = URLSessionConfiguration.background(withIdentifier: "valentynponomarenko.CurrencyConverter.backgroundTask")
        } else {
            configuration = URLSessionConfiguration.default
        }
        
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    func fetchCurrentRates() async {
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

// MARK: - URLSessionDataTask
extension RatesNetworkManager: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let currentRates = parseJSON(withData: data) else { return }
        
        DispatchQueue.main.async {
            self.coreDataManager.createCurrencyRatesCache(rates: currentRates)
            self.coreDataManager.createLastFetchTime(currentFetchDate: Date())
        }
        
        NotificationCenter.default.post(name: .ratesFetchCompleted, object: nil, userInfo: ["success": true])
    }
}
