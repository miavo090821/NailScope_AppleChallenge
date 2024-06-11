import SwiftUI

struct HomeView: View {
    @State private var detectedImage: UIImage?
    @State private var scrollView: UIScrollView!
    @State private var photoButtonTapped: Int?
    @State private var selectedShapePhoto: UIImage?
    
    // Define photo shape names
    let photoShapeNames = ["shape1", "shape2", "shape3", "shape4", "shape5", "shape6"]
    // Define saved photos
    let savedPhotos = ["art 1", "art 3", "art 5"]
    
    // Define a custom structure to hold both the image name and its custom text
    struct PhotoShape {
        let imageName: String
        let customText: String
    }

    // Define an array of PhotoShape instances
    let photoShapes: [PhotoShape] = [
        PhotoShape(imageName: "shape1", customText: "Coffin"),
        PhotoShape(imageName: "shape2", customText: "Round"),
        PhotoShape(imageName: "shape3", customText: "Squoval"),
        PhotoShape(imageName: "shape4", customText: "Almond"),
        PhotoShape(imageName: "shape5", customText: "Ballenria"),
        PhotoShape(imageName: "shape6", customText: "Square"),
        
    ]

    func presentWhatsthetrend() {
        self.showWhatsthetrend.toggle()
    }

    @State private var showSettings = false
    @State private var isTabOpen = false
    @State private var showWhatsthetrend = false
    @State private var exploreClicked = false
    @State private var designClicked = false
    @State private var tryCamClicked = false

    let tabBar: TabBar

    init(tabBar: TabBar) {
        self.tabBar = tabBar
    }

    var body: some View {
        NavigationView {
            ZStack {
                Image("ImageBackground1")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.5)

                VStack {
                    Spacer()

                    // What's the Trend button
                    Button(action: {
                        self.presentWhatsthetrend()
                    }) {
                        Text("What's the trend now?🏃‍♂️")
                            .foregroundColor(Color("Tip Background"))
                    }
                    .sheet(isPresented: $showWhatsthetrend) {
                        WhatsthetrendView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, -700)

                    Spacer(minLength: 100)

                    Spacer()
                    
                    // Display the photo shapes without buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(photoShapes, id: \.imageName) { photoShape in
                                VStack {
                                    Image(photoShape.imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 70)
                                    
                                    Text(photoShape.customText)
                                        .foregroundColor(.purple)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 100) // Set the fixed height for the ScrollView
                    .padding(.bottom, 300) // Adjust spacing between photo shapes and button

                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: EmptyView(),
                    trailing: Button(action: {
                        // Action for setting button
                        self.showSettings.toggle()
                    }) {
                        Image("Setting button")
                            .renderingMode(.template)
                            .foregroundColor(.purple)
                    }
                )
                .navigationBarTitle("", displayMode: .inline)
                .overlay(
                    Text("💅NailScope 👀")
                    
                        .font(.largeTitle)
                        .foregroundColor(Color("Tip Background"))
                        .padding(.top, -50), alignment: .top // Move the text to the top
                )
                .sheet(isPresented: $showSettings) {
                    // Present settings view
                    SettingView()
                }
                .overlay(tabBar)
// MARK: Bottle Buttons
                
                VStack {
                    Spacer()
                    HStack(spacing: 18) {
                        NavigationLink(
                            destination: ExploreView(),
                            isActive: $exploreClicked,
                            label: {
                                bottleButton(bottleImage: "explore bottle", lidImage: "explore lid", buttonText: " Explore\n🔍") {
                                    self.exploreClicked = true
                                }
                            }
                        )

                        NavigationLink(
                            destination: DesignViewController(),
                            isActive: $designClicked,
                            label: {
                                bottleButton(bottleImage: "design bottle", lidImage: "design lid", buttonText: "Design \n🔮") {
                                    self.designClicked = true
                                }
                            }
                        )

                        NavigationLink(
                            destination: CameraViewWrapper(detectedImage: $detectedImage),
                            isActive: $tryCamClicked,
                            label: {
                                bottleButton(bottleImage: "try cam bottle", lidImage: "try cam lid", buttonText: "\nVirtual\nCamera\n📸") {
                                    self.tryCamClicked = true
                                }
                            }
                        )
                    }
                }// Adjust the overall offset of the button content
                .offset(y: -440)
            }
        }
    }
    
    @ViewBuilder
    func bottleButton(bottleImage: String, lidImage: String, buttonText: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Image(bottleImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 120)

                Image(lidImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .offset(y: -100) // Adjust the lid position if needed

                VStack(spacing: 8) {
                    ForEach(buttonText.components(separatedBy: "\n"), id: \.self) { line in
                        Text(line)
                            .foregroundColor(.black)
                            .font(.system(size: 10, weight: .bold))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(tabBar: TabBar(savedPhotos: ["art 1", "art 3", "art 5"])) // Pass saved photos
    }
}

struct CameraViewWrapper: UIViewRepresentable {
    @Binding var detectedImage: UIImage?

    func makeUIView(context: Context) -> CameraView {
        let screenBounds = UIScreen.main.bounds
        let defaultImage = UIImage(named: "defaultImage") ?? UIImage()
        let cameraView = CameraView(frame: screenBounds, parentViewController: nil, detectedImage: detectedImage ?? defaultImage)
        return cameraView
    }

    func updateUIView(_ uiView: CameraView, context: Context) {
        uiView.detectedImage = detectedImage ?? UIImage()
    }
}


struct DesignViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let hostingController = UIHostingController(rootView: DesignView())
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}
