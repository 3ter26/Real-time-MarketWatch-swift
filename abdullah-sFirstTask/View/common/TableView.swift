import SwiftUI

struct TableView: View {
    @Binding var trades:[TradeObject]
    
    var body: some View {
        HeaderSectionView()
        List(trades) { item in
            CellView(tradeObject: item)
        }
        .listStyle(.plain)
        .onAppear {
            TradeObjectService.shared.fillTradeObjects(trades: $trades)
            WebSocketService.shared.connectToStreamer(trades: $trades)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var trades = [TradeObject]()

            var body: some View {
                TableView(trades: $trades)
            }
        }
        return PreviewWrapper()
}
