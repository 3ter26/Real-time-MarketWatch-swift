import SwiftUI

struct MarketWatchView: View {
    @State var trades = TradeModel()
    
    var body: some View {
        TableView(trades: $trades.trades)
    }
}



#Preview {
    MarketWatchView()
}
