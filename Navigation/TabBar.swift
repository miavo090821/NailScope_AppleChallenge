import SwiftUI

struct TabBar: View {
    var savedPhotos: [String] // Array to store saved photos
    
    var body: some View {
        VStack {
            Spacer() // Move content to the top
            
            Spacer() // Move content to the bottom
            
            HStack {
                NavigationLink(destination: TipandCareView()) {
                    Image("menu button")
                        .resizable()
                        .frame(width: 70, height: 70)
                }
                
                Spacer()
                
                NavigationLink(destination: SavedView(savedPhotos: savedPhotos)) {
                    Image("saved button")
                        .resizable()
                        .frame(width: 60, height: 60)
                }
            }
            .font(.title2)
            .padding(EdgeInsets(top: 10, leading: 50, bottom:24, trailing: 50))
        }
        .frame(width: 400)
        .frame(height: 70)
        .background(Color.clear)
        .ignoresSafeArea()
        .padding(.top,700) 
    }
}

struct TabBar_Preview: PreviewProvider {
    static var previews: some View {
        TabBar(savedPhotos: ["art 1", "art 3", "art 5"]) // Example of passing saved photos
            .preferredColorScheme(.light)
    }
}
