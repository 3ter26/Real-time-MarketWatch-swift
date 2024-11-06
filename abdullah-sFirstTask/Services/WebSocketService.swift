import Foundation
import SwiftUI

class WebSocketService: NSObject, URLSessionWebSocketDelegate {
    static let shared = WebSocketService()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    private var pingTimer: Timer?
    private var tradesBinding: Binding<[TradeObject]>?
    private let streamerURL = "removed_for_company_security_reasons"
    
    private var animationVariable1 = 0
    private var animationVariable2 = 0
    private var animationVariable3 = 0
    private var animationVariable4 = 0
    
    func connectToStreamer(trades: Binding<[TradeObject]>) {
        tradesBinding = trades
        guard let url = URL(string: streamerURL) else { return }
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
    }
    
    private func startPingTimer() {
        DispatchQueue.main.async {
            self.pingTimer?.invalidate()
            self.pingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
                self?.ping()
            }
        }
    }
    
    func subscribeToTopics(trades: Binding<[TradeObject]>) {
        let dispatchGroup = DispatchGroup()
        let symbols = trades.wrappedValue.compactMap { $0.symbol }
        let topicsForUnsubscription = symbols.map { "unsubscribe=QO.\($0)" }
        let topicsForSubscription = symbols.map { "subscribe=QO.\($0)" }
        
        for (unsubTopic, subTopic) in zip(topicsForUnsubscription, topicsForSubscription) {
            dispatchGroup.enter()
            unsubscribeFromTopic(unsubTopic)
            subscribeToTopic(subTopic) {
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.messageListener(tradeObjectsInUI: trades)
        }
    }
    
    private func unsubscribeFromTopic(_ message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("Error while unsubscribing: \(error)")
            } else {
                print("Unsubscribed from: \(message)")
            }
        }
    }
    
    private func subscribeToTopic(_ message: String, completion: @escaping () -> Void) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("Error while subscribing: \(error)")
            } else {
                print("Subscribed to: \(message)")
            }
            completion()
        }
    }
    
    func passUUID(completion: @escaping () -> Void) {
        let uuidMessage = "uid=\(UUID().uuidString)"
        webSocketTask?.send(.string(uuidMessage)) { error in
            if let error = error {
                print("Error while sending UUID: \(error)")
            } else {
                print("UUID sent successfully: \(uuidMessage)")
                completion()
            }
        }
    }
    
    func messageListener(tradeObjectsInUI: Binding<[TradeObject]>) {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.parseResponse(response: text, tradeObjectsInUI: tradeObjectsInUI)
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    print("Unknown message type received")
                }
                self?.messageListener(tradeObjectsInUI: tradeObjectsInUI)
            }
        }
    }
    
    private func parseResponse(response: String, tradeObjectsInUI: Binding<[TradeObject]>) {
        do {
            if let jsonData = response.data(using: .utf8),
               let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                print("JSON: \(json)")
                processReceivedMessage(dictionary: json, tradeObjectsInUI: tradeObjectsInUI)
            } else {
                print("Invalid JSON data")
            }
        } catch {
            print("Failed parsing: \(error)")
        }
    }
    
    private func processReceivedMessage(dictionary: [String: Any], tradeObjectsInUI: Binding<[TradeObject]>) {
        guard let topic = dictionary["topic"] as? String,
              let symbolSuffix = topic.split(separator: ".").last,
              let index = tradeObjectsInUI.wrappedValue.firstIndex(where: { $0.symbol == String(symbolSuffix) }) else {
            return
        }
        
        let currentTradeObject = tradeObjectsInUI.wrappedValue[index]
        
        DispatchQueue.main.async {
            if let askPriceString = dictionary["askprice"] as? String,
               let askPrice = Double(askPriceString),
               currentTradeObject.askPrice != askPrice {
                self.animationVariable1 += 1
                tradeObjectsInUI.wrappedValue[index].askPrice = askPrice
            }
            if let lastTradePriceString = dictionary["lasttradeprice"] as? String,
               let lastTradePrice = Double(lastTradePriceString),
               currentTradeObject.lastPrice != lastTradePrice {
                self.animationVariable2 += 1
                tradeObjectsInUI.wrappedValue[index].lastPrice = lastTradePrice
            }
            if let highPriceString = dictionary["high"] as? String,
               let highPrice = Double(highPriceString),
               currentTradeObject.highPrice != highPrice {
                self.animationVariable3 += 1
                tradeObjectsInUI.wrappedValue[index].highPrice = highPrice
            }
            if let bidPriceString = dictionary["bidprice"] as? String,
               let bidPrice = Double(bidPriceString),
               currentTradeObject.bidPrice != bidPrice {
                self.animationVariable4 += 1
                tradeObjectsInUI.wrappedValue[index].bidPrice = bidPrice
            }
        }
    }
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func ping() {
        webSocketTask?.sendPing { error in
            if let error = error {
                print("Ping failed: \(error)")
            } else {
                print("Ping successful")
            }
        }
    }
    
    func disconnectFromStreamer() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected")
        passUUID {
            if let trades = self.tradesBinding {
                self.subscribeToTopics(trades: trades)
            }
        }
        startPingTimer()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("WebSocket disconnected with error: \(error)")
        } else {
            print("WebSocket disconnected normally")
        }
        stopPingTimer()
    }
}
