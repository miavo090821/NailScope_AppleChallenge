import SwiftUI

struct DetectionResultView: View {
    let detectedImages: [UIImage]
    let boundingBox: CGRect?
    
    @State private var selectedImageIndex: Int?
    @State private var isActionSheetPresented = false
    @State private var updatedImages: [UIImage]
    @State private var selectedImage: UIImage?
    
    @State private var isCameraViewPresented = false
    
    init(detectedImages: [UIImage], boundingBox: CGRect?) {
        self.detectedImages = detectedImages
        self.boundingBox = boundingBox
        self._updatedImages = State(initialValue: detectedImages)
    }
    private func rotateImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            return image
        }
        
        let fullRotation = CGFloat.pi * 2.0
        let increment = CGFloat.pi / 18.0 // Rotate in 10-degree increments
        var rotatedImage = image
        
        for angle in stride(from: 0.0, to: fullRotation, by: increment) {
            let rotatedSize = CGSize(width: cgImage.width, height: cgImage.height)
            UIGraphicsBeginImageContextWithOptions(rotatedSize, false, 1.0)
            defer { UIGraphicsEndImageContext() }
            
            if let context = UIGraphicsGetCurrentContext() {
                context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
                context.rotate(by: angle)
                context.draw(cgImage, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
            }
            
            if let rotated = UIGraphicsGetImageFromCurrentImageContext() {
                rotatedImage = rotated
            }
        }
        
        return rotatedImage
    }


    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(detectedImages.indices, id: \.self) { index in
                    DetectedImageView(image: $updatedImages[index])
                        .onTapGesture {
                            self.selectedImageIndex = index
                            self.isActionSheetPresented = true
                        }
                        .id(UUID())
                }
            }
            .padding()
        }
        .navigationBarTitle("Detection Results")
        .actionSheet(isPresented: $isActionSheetPresented) {
            ActionSheet(title: Text("Select an option"), buttons: [
                .default(Text("Rotate")) {
                    if let index = self.selectedImageIndex, index < self.updatedImages.count {
                        self.updatedImages[index] = self.rotateImage(self.updatedImages[index])
                    }
                },
                .default(Text("Apply to Camera")) {
                    if let index = self.selectedImageIndex, index < self.updatedImages.count {
                        self.selectedImage = self.updatedImages[index]
                        self.isCameraViewPresented = true
                    }
                },
                .cancel()
            ])
        }
        // Use CameraViewWrapper to pass the selected image to CameraView
        .sheet(isPresented: $isCameraViewPresented) {
            CameraViewWrapper(detectedImage: $selectedImage)
                .onAppear {
                    // Access the showPhoto function directly from CameraView
                    if let image = self.selectedImage {
                        let cameraView = CameraView(frame: .zero, parentViewController: nil, detectedImage: image)
                        cameraView.showPhoto(image, at: CGPoint(x: 100, y: 100), forFinger: "thumb")
                        // Adjust the finger parameter as needed based on your implementation
                    }
                }
        }

    }
}


    
    
    
struct DetectedImageView: View {
    @Binding var image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .border(Color.gray)
    }
}
