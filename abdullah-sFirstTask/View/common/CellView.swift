import SwiftUI

struct  CellView: View {
    let tradeObject: TradeObject
    @State private var highlight1 = false
    @State private var highlight2 = false
    @State private var highlight3 = false
    @State private var highlight4 = false
    
    var body: some View {
        HStack {
            Text(tradeObject.symbol?.suffix(8) ?? "-")
                .foregroundColor(.black)
                .frame(maxWidth: 80, alignment: .leading)
            Spacer()
            Text("\(tradeObject.name ?? "-")")
                .frame(maxWidth: 70, alignment: .leading)
            Spacer()
            HStack() {
                TextView(highlight: $highlight1, value: String("\(tradeObject.askPrice ?? 0.0)"), onChangeVar: animationVariable1)
                Spacer()
                TextView(highlight: $highlight2, value: String("\(tradeObject.lastPrice ?? 0.0)"), onChangeVar: animationVariable2)
                Spacer()
                TextView(highlight: $highlight3, value: String("\(tradeObject.bidPrice ?? 0.0)"), onChangeVar: animationVariable3)
                Spacer()
                TextView(highlight: $highlight4, value: String("\(tradeObject.highPrice ?? 0.0)"), onChangeVar: animationVariable4)
            }
        }
        .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
        .padding(.vertical, 3)
        .foregroundColor(.gray)
    }
}








#Preview {
    CellView(tradeObject: TradeObject(
        topic: "Sym"))
}
