import SwiftUI
import CoreML
import Vision

class DesignViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var showActionSheet: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera
    @Published var isDetecting: Bool = false
    @Published var modifiedImage: UIImage?
    @Published var detectedImages: [UIImage] = []
    @Published var boundingBox: CGRect?
    
    //MARK: Add trained Machine Learning model on Object detection (finger nails)
    let nailsFingerModel = NailsFinger25()
    
    func saveDetectedImage(image: UIImage) {
        detectedImages.append(image)
    }
}

struct ImageView: View {
    var selectedImage: UIImage?
    
    var body: some View {
        if let image = selectedImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 400)
                .clipped()
        } else {
            Text("No Image Selected")
        }
    }
}

struct DesignView: View {
    @StateObject private var viewModel = DesignViewModel()
    @State private var showingDetectionResults = false

    var body: some View {
        NavigationView {
            VStack {
                ImageView(selectedImage: viewModel.modifiedImage ?? viewModel.selectedImage)
                    .padding()
                
                CameraButtonView(showActionSheet: $viewModel.showActionSheet)
                
                DetectionButtonView()
                    .environmentObject(viewModel)
                
                // Button to navigate to DetectionResultView
                Button("View Detection Results") {
                    showingDetectionResults.toggle()
                }
                .padding()
                // NavigationLink to navigate to DetectionResultView
                NavigationLink(destination: DetectionResultView(detectedImages: viewModel.detectedImages, boundingBox: viewModel.boundingBox).environmentObject(viewModel), isActive: $showingDetectionResults){
                }

                
                Spacer()
            }
            .padding(100)
            .background(.exploreBackground)
        }
        .navigationBarTitle("Design View", displayMode: .inline)
                .navigationBarItems(trailing: EmptyView())
                .navigationBarTitleDisplayMode(.automatic)
                .actionSheet(isPresented: $viewModel.showActionSheet) {
            ActionSheet(title: Text("Select Image"),
                        message: Text("Please select the image from the gallery or use the camera"),
                        buttons: [
                            .default(Text("Camera")) {
                                viewModel.sourceType = .photoLibrary
                                viewModel.showImagePicker.toggle()
                            },
                            .default(Text("Photo Gallery")) {
                                viewModel.sourceType = .camera
                                viewModel.showImagePicker.toggle()
                            },
                            .cancel()
                        ])
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(isVisible: $viewModel.showImagePicker, selectedImage: $viewModel.selectedImage, sourceType: viewModel.sourceType.rawValue)
                .environmentObject(viewModel)
                .onDisappear {
                    if let selectedImage = viewModel.selectedImage {
                        viewModel.modifiedImage = selectedImage
                    }
                }
        }
    }
}


struct DetectionButtonView: View {
    @EnvironmentObject var viewModel: DesignViewModel
    
    var body: some View {
        Button("Detect Finger Nails") {
            if let image = viewModel.selectedImage {
                viewModel.isDetecting = true
                viewModel.detectFingerNails(image: image)
            }
        }
    }
}

extension DesignViewModel {
    func detectFingerNails(image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create CIImage from UIImage")
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([detectionRequest])
        } catch {
            print("Failed to perform detection: \(error.localizedDescription)")
        }
    }
    
    private var detectionRequest: VNCoreMLRequest {
        do {
            let model = try VNCoreMLModel(for: nailsFingerModel.model)
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    print("Unable to detect anything: \(error?.localizedDescription ?? "")")
                    return
                }
                self?.processDetectionResults(results)
            }
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }
    
    private func processDetectionResults(_ results: [VNRecognizedObjectObservation]) {
        if let image = self.selectedImage {
            // Draw the bounding boxes on the image
            drawDetectionOnPreview(detections: results, originalImage: image)
            
            // Crop the detected regions
            let croppedImages = cropDetectedRegions(detections: results, originalImage: image)
            
            for croppedImage in croppedImages {
                saveDetectedImage(image: croppedImage)
            }
        }
    }
    private func drawDetectionOnPreview(detections: [VNRecognizedObjectObservation], originalImage: UIImage) {
        DispatchQueue.main.async {
            let imageSize = originalImage.size
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
            originalImage.draw(at: .zero)
            
            for detection in detections {
                let boundingBox = detection.boundingBox
                let rect = CGRect(x: boundingBox.minX * imageSize.width,
                                  y: boundingBox.minY * imageSize.height,
                                  width: boundingBox.width * imageSize.width,
                                  height: boundingBox.height * imageSize.height)
                
                // Convert CGRect from Vision coordinates to UIImage coordinates
                let normalizedRect = CGRect(x: rect.origin.x,
                                            y: imageSize.height - rect.origin.y - rect.size.height,
                                            width: rect.size.width,
                                            height: rect.size.height)
                
                // Draw the bounding box
                UIColor(red: 0, green: 1, blue: 0, alpha: 0.4).setStroke()
                let path = UIBezierPath(rect: normalizedRect)
                path.lineWidth = 5
                path.stroke()
            }
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.modifiedImage = newImage
        }
    }

    private func cropDetectedRegions(detections: [VNRecognizedObjectObservation], originalImage: UIImage) -> [UIImage] {
        var croppedImages: [UIImage] = []
        
        for detection in detections {
            let boundingBox = detection.boundingBox
            let imageSize = originalImage.size
            
            let cropRect = CGRect(x: boundingBox.minX * imageSize.width,
                                  y: (1 - boundingBox.minY - boundingBox.height) * imageSize.height,
                                  width: boundingBox.width * imageSize.width,
                                  height: boundingBox.height * imageSize.height)
            
            guard let croppedCGImage = originalImage.cgImage?.cropping(to: cropRect) else {
                print("Failed to crop image")
                continue
            }
            
            let croppedImage = UIImage(cgImage: croppedCGImage)
            croppedImages.append(croppedImage)
        }
        
        return croppedImages
    }
}

struct DesignView_Previews: PreviewProvider {
    static var previews: some View {
        DesignView()
    }
}
