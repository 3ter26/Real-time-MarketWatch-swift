import Foundation

struct TradeObject: Codable, Identifiable {
    var name: String?
    var askPrice, lastPrice, bidPrice, highPrice: Double?
    var symbol: String?
    var change: Double?
    let id = UUID()
    
    enum CodingKeys: String, CodingKey {
        case name
        case askPrice = "ask-price"
        case lastPrice = "last-price"
        case bidPrice = "bid-price"
        case highPrice = "high-price"
    }
    
    enum WebSocketKeys: String, CodingKey {
        case name
        case symbol = "topic"
        case lastPrice = "lasttradeprice"
        case askPrice = "askprice"
        case bidPrice = "bidprice"
        case highPrice = "high"
    }
    
    init(topic: String) {
        self.name = ""
        self.askPrice = 0.0
        self.lastPrice = 0.0
        self.bidPrice = 0.0
        self.highPrice = 0.0
        self.symbol = topic
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let webSocketContainer = try? decoder.container(keyedBy: WebSocketKeys.self)
        
        if let webSocketContainer = webSocketContainer, webSocketContainer.contains(.symbol) {
            symbol = try webSocketContainer.decodeIfPresent(String.self, forKey: .symbol)
            if let updatedname = try? webSocketContainer.decodeIfPresent(String.self, forKey: .name) {
                name=updatedname
            }
            lastPrice = try TradeObject.decodingHelper(from: webSocketContainer, forKey: .lastPrice)
            askPrice = try TradeObject.decodingHelper(from: webSocketContainer, forKey: .askPrice)
            bidPrice = try TradeObject.decodingHelper(from: webSocketContainer, forKey: .bidPrice)
            highPrice = try TradeObject.decodingHelper(from: webSocketContainer, forKey: .highPrice)
        } else {
            name = try container.decode(String.self, forKey: .name)
            askPrice = try container.decode(Double.self, forKey: .askPrice)
            lastPrice = try container.decode(Double.self, forKey: .lastPrice)
            bidPrice = try container.decode(Double.self, forKey: .bidPrice)
            highPrice = try container.decode(Double.self, forKey: .highPrice)
            symbol = nil
        }
    }
    
    private static func decodingHelper(from container: KeyedDecodingContainer<WebSocketKeys>, forKey key: WebSocketKeys) throws -> Double? {
        do {
            if let doubleValue = try container.decodeIfPresent(Double.self, forKey: key){
                return doubleValue
            }
        } catch DecodingError.typeMismatch {
            if let stringValue = try container.decodeIfPresent(String.self, forKey: key){
                guard let doubleValue = Double(stringValue) else {
                    throw DecodingError.typeMismatch(Double.self, DecodingError.Context(codingPath: [key], debugDescription: "Error decoding Double data type"))
                }
                return doubleValue
            }
        }
        return nil
    }
}
