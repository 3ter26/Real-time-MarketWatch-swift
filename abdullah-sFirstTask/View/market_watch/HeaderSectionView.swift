import SwiftUI

struct HeaderSectionView: View {

    var body: some View {
            VStack {
                HStack {
                    Text("Symbol")
                        .frame( alignment: .leading)
                        .padding(.leading, 5)
                    Spacer()
                    Text("Name")
                        .padding(.leading,10)
                    Spacer()
                    Text("Ask Price").frame(maxWidth: 50)
                        .padding(.leading,10)
                    Spacer()
                    Text("Last Price").frame(maxWidth: 50)
                        .padding(.leading,15)
                    Spacer()
                    
                    Text("Bid Price").frame(maxWidth: 50)
                        .padding(.leading,15)
                    Spacer()
                    
                    Text("High Price").frame(maxWidth: 50)
                }
                .font(.headline)
                Divider()
                    .frame(height: 1.5)
                    .background(Color.black)
                .listRowInsets(.init(top:10, leading: 10, bottom: 10, trailing: 10))
                
            }
            
            
        
        
    }
}

#Preview {
    HeaderSectionView()
}
