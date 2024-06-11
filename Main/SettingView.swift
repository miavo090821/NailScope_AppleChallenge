import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) var dismiss
    
    let rectangleData: [(String, Color)] = [
        ("Account", Color.background1),
        ("Terms and conditions", Color.background2),
        ("Version", Color("What's the trend")),
        ("About us", Color("Tip Background")) ]
    
    var body: some View {
        ZStack{
            // MARK: Background
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing:8){
                HStack {
                    // MARK: Back button
                    Button{
                        dismiss()
                    } label:{
                        HStack(spacing:50){
                            Text("     Setting ")
                                .font(.custom("Inter-SemiBold", fixedSize: 29))
                                .foregroundColor(Color("Tip Background"))
                        }
                        .frame(height:34)
                    }
                    Spacer()
                }.frame(height:92)
                
                // Four Rectangles with Custom Text Inside
                ForEach(rectangleData.indices, id: \.self) { index in
                    HStack {
                        Rectangle()
                            .fill(rectangleData[index].1)
                            .frame(width: 350, height: 50)
                            .overlay(
                                Text(rectangleData[index].0)
                                    .foregroundColor(.black)
                                    .padding(.leading, -166)
                            )
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 20)
                }
            }
            .padding(.top, 49)
            .padding(.bottom, 16) 
            .frame(maxHeight:.infinity,alignment: .top)
            .ignoresSafeArea()
        }
        .navigationBarHidden(true)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .preferredColorScheme(.light)
    }
}
