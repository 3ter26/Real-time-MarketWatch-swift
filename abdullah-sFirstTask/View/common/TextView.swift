import SwiftUI

struct TextView: View {
    @Binding var highlight: Bool
    var value: String
    var onChangeVar: Int
    
    var body: some View {
        Text(value.prefix(5))
            .background(self.highlight ? Color.red : Color.clear)
            .onChange(of: onChangeVar){
                self.highlight = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.highlight = false
                }
            }
            .animation(.easeInOut, value: highlight)
    }
}

#Preview {
    TextView(highlight: .constant(false), value: "this TextView", onChangeVar: 0)
}
