import SwiftUI


struct CameraButtonView: View {
    @Binding var showActionSheet: Bool

    var body: some View {
        Button(action: {
            self.showActionSheet.toggle()
        }) {
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 350, height: 40, alignment: .center)
                .foregroundColor(Color("Chrome background"))
                .overlay(
                    RoundedRectangle(cornerRadius: 60)
                        .frame(width:350, height: 40, alignment: .center)
                        .foregroundColor(Color("Background 1"))
                        .overlay(
                            Image(systemName: "camera.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30) 
                                .foregroundColor(Color("Background 2"))
                        )
                )
        }
    }
}

struct CameraButtonView_Preview: PreviewProvider {
    static var previews: some View {
        CameraButtonView(showActionSheet: .constant(false))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
