import Foundation
import SwiftUI

final class TradeObjectService {
    static let shared = TradeObjectService()
    
    private let tickerChartURL = "removed_for_company_security_reason"
    private let fixedTradeObjectsJSON = "fixedTradeObjects.json"
    private let session = URLSession.shared
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func fetchTradeObjects(trades: Binding<[TradeObject]>) {
        guard let url = URL(string: tickerChartURL) else {
            print("Invalid URL")
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let decodedData = try self.decoder.decode([TradeObject].self, from: data)
                DispatchQueue.main.async {
                    trades.wrappedValue = decodedData
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    func loadFixedTradeObjects(trades: Binding<[TradeObject]>) {
        guard let fileURL = Bundle.main.url(forResource: fixedTradeObjectsJSON, withExtension: nil) else {
            print("Couldn't find \(fixedTradeObjectsJSON) in main bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decodedData = try decoder.decode([TradeObject].self, from: data)
            DispatchQueue.main.async {
                trades.wrappedValue = decodedData
            }
        } catch {
            print("Error loading or parsing \(fixedTradeObjectsJSON): \(error)")
        }
    }
}
