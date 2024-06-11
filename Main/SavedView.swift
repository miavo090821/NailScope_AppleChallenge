import SwiftUI

struct SavedView: View {
    @Environment(\.dismiss) var dismiss
    var savedPhotos: [String] // Array to store saved photos
    
    var body: some View {
        NavigationView {
            ZStack {
                // MARK: Background
                Color.background
                    .ignoresSafeArea()
                
                VStack(spacing:8) {
                    HStack {
                        // MARK: Back button
                        Button {
                            dismiss()
                        } label:{
                            HStack(spacing:15) {
                            Text("     Saved Nails Design")
                                    .font(.custom("Inter-SemiBold", fixedSize: 19))
                                    .foregroundColor(Color("Tip Background"))
                            }
                            .frame(height:44)
                        }
                        Spacer()
                        // MARK: More Button
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size:28))
                            .frame(width:44,height: 44,alignment: .trailing)
                            .foregroundColor(Color("Tip Background"))
                    }.frame(height:-100)
                    
                }
                .frame(height:80,alignment:.top)
                .padding(.horizontal,16)
                .padding(.top,70)
                .frame(maxHeight:.infinity,alignment: .top)
                .ignoresSafeArea()
                
                VStack { // New VStack to contain the ScrollView
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 56) {
                            ForEach(0..<10) { index in
                                if index < savedPhotos.count {
                                    Image(savedPhotos[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .cornerRadius(8)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.top, 30)
                    .frame(maxHeight: .infinity)
                }
                .padding(.bottom, 10)
            }
            .navigationBarHidden(true)
        }
    }
}

struct SavedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedView(savedPhotos: ["art 1"])
            .preferredColorScheme(.light)
    }
}
