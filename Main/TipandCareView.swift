import SwiftUI

struct TipItem {
    var title: String
    var text: String
}

struct TipandCareView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isExpanded: [Bool] = [false, false, false, false, false, false] // Array to track expansion state
    
    let tips: [TipItem] = [
        TipItem(title: "Tip 1: Nail Hydration", text: "Keep your nails hydrated by regularly applying a moisturizing nail cream or oil."),
        TipItem(title: "Tip 2: Cuticle Care", text: "Gently push back your cuticles using a cuticle pusher to promote healthy nail growth."),
        TipItem(title: "Tip 3: Nail Strengthening", text: "Use a nail strengthener or hardener to prevent breakage and promote stronger nails."),
        TipItem(title: "Tip 4: Proper Filing Technique", text: "File your nails in one direction to avoid splitting and weakening the nails."),
        TipItem(title: "Tip 5: Avoid Harsh Chemicals", text: "Limit exposure to harsh chemicals such as acetone and bleach to maintain nail health."),
        TipItem(title: "Tip 6: Healthy Diet", text: "Maintain a balanced diet rich in vitamins and minerals to support strong and healthy nails.")
    ]
    
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
                        HStack(spacing:5){
                            //MARK: Back Button icon
                            Image(systemName: "chevron.left")
                                .font(.system(size: 23).weight(.medium))
                                .foregroundColor(.purple)
                            //MARK: Back button label
                            Text("   Tips and Care")
                                .font(.custom("Inter-SemiBold", fixedSize: 29))
                                .foregroundColor(Color("Tip Background"))
                        }
                        .frame(height:44)
                    }
                    Spacer()
                                    }.frame(height:52)
                    
                    ScrollView {
                        ForEach(0..<6) { index in
                            VStack {
                                HStack {
                                    Text(tips[index].title)
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                    Spacer()
                                    Button(action: {
                                        isExpanded[index].toggle()
                                    }) {
                                        Image(systemName: isExpanded[index] ? "chevron.up" : "chevron.down")
                                            .foregroundColor(.purple)
                                    }
                                }
                                .padding(.horizontal)
                                if isExpanded[index] {
                                    Text(tips[index].text)
                                        .foregroundColor(.black)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        }
                    }
                }
                .padding(.top,2)
                .padding(.bottom, 16)
                .navigationBarHidden(true)
            }
            .foregroundColor(Color("Tip Background"))
            .preferredColorScheme(.light)
        }
    }

    
    struct TipandCareView_Previews: PreviewProvider {
        static var previews: some View {
            TipandCareView()
        }
    }

