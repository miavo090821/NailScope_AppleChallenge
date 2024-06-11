import UIKit
import AVFoundation
import Vision

// MARK: Handle error
enum AppError: Error {
    case captureSessionSetup(reason: String)
    case visionError(error: Error)
    case otherError(error: Error)
    
    static func display(_ error: Error, inViewController viewController: UIViewController) {
        if let appError = error as? AppError {
            appError.displayInViewController(viewController)
        } else {
            AppError.otherError(error: error).displayInViewController(viewController)
        }
    }
    
    func displayInViewController(_ viewController: UIViewController) {
        let title: String?
        let message: String?
        switch self {
        case .captureSessionSetup(let reason):
            title = "AVSession Setup Error"
            message = reason
        case .visionError(let error):
            title = "Vision Error"
            message = error.localizedDescription
        case .otherError(let error):
            title = "Error"
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
// MARK: Camera view with Vision (hard part :))

class CameraView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var cameraSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private weak var parentViewController: UIViewController?
    private let drawOverlay = CAShapeLayer()
    private var lastObservationTimestamp = Date()
    private var selectedPhoto: UIImage?
    private var photoButtonsStackView: UIStackView!
    private var photoImages: [UIImage] = []
    private var scrollView: UIScrollView!
    private var photoSize: CGSize = .zero
    private var selectedImage: UIImage?
    var detectedImage: UIImage? // Change to non-optional
    
    //MARK: Customised Color options
    private var colorOptions: [(CGFloat, CGFloat, CGFloat)] = [
        (1.0, 0.0, 0.0),
        (0.7176, 0.5529, 0.7725),
        (0.3961, 0.2667, 0.4431),
        (0.2118, 0.7490, 0.6196),
        (0.8275, 0.6510, 0.6510),
        (0.5686, 0.4196, 0.6235),
        (168.0 / 255.0, 227.0 / 255.0, 184.0 / 255.0),
            (37.0 / 255.0, 51.0 / 255.0, 41.0 / 255.0),
            (109.0 / 255.0, 164.0 / 255.0, 207.0 / 255.0),
            (227.0 / 255.0, 120.0 / 255.0, 206.0 / 255.0),
            (252.0 / 255.0, 164.0 / 255.0, 205.0 / 255.0),
            (69.0 / 255.0, 35.0 / 255.0, 51.0 / 255.0),
            (122.0 / 255.0, 37.0 / 255.0, 77.0 / 255.0),
            (194.0 / 255.0, 31.0 / 255.0, 53.0 / 255.0),
            (230.0 / 255.0, 32.0 / 255.0, 58.0 / 255.0),
            (51.0 / 255.0, 5.0 / 255.0, 11.0 / 255.0),
            (41.0 / 255.0, 2.0 / 255.0, 7.0 / 255.0),
            (242.0 / 255.0, 182.0 / 255.0, 109.0 / 255.0),
            (204.0 / 255.0, 147.0 / 255.0, 78.0 / 255.0),
            (166.0 / 255.0, 184.0 / 255.0, 77.0 / 255.0),
            (80.0 / 255.0, 92.0 / 255.0, 20.0 / 255.0),
            (137.0 / 255.0, 250.0 / 255.0, 122.0 / 255.0),
            (49.0 / 255.0, 97.0 / 255.0, 43.0 / 255.0),
            (248.0 / 255.0, 250.0 / 255.0, 247.0 / 255.0),
            (220.0 / 255.0, 224.0 / 255.0, 220.0 / 255.0),
            (131.0 / 255.0, 133.0 / 255.0, 131.0 / 255.0),
            (13.0 / 255.0, 13.0 / 255.0, 12.0 / 255.0)
        ]

    
    private var selectedColor: UIColor = .clear
    private lazy var colorButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    init(frame: CGRect, parentViewController: UIViewController?, detectedImage: UIImage) {
        super.init(frame: frame)
        self.parentViewController = parentViewController
        setupCameraSession()
        setupDrawOverlay()
        setupColorOptions()
        setupPhotoButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCameraSession()
        setupDrawOverlay()
    }
    
    private func setupCameraSession() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession = AVCaptureSession()
            cameraSession?.addInput(input)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession!)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = bounds
            
            layer.addSublayer(previewLayer)
            
            cameraSession?.startRunning()
            
            // Setup AVCaptureVideoDataOutput
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            cameraSession?.addOutput(videoDataOutput)
        } catch {
            print("Error setting up camera session: \(error.localizedDescription)")
        }
    }
    
    private func setupDrawOverlay() {
        drawOverlay.frame = layer.bounds
        drawOverlay.lineWidth = 5
        drawOverlay.backgroundColor = UIColor.clear.cgColor // Change to clear color :)
        drawOverlay.strokeColor = UIColor(red: 0.6, green: 0.1, blue: 0.3, alpha: 1).cgColor
        drawOverlay.fillColor = UIColor(white: 1, alpha: 0).cgColor
        drawOverlay.lineCap = .round
        layer.addSublayer(drawOverlay)
    }
    
    // MARK: handle with Vision and points from AV to UIKIT (complicated part)
    
    private func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?, middleTip: CGPoint?, ringTip: CGPoint?, littleTip: CGPoint?) {
        // Check that we have all points.
        guard let thumbPoint = thumbTip, let indexPoint = indexTip, let middlePoint = middleTip, let ringPoint = ringTip, let littlePoint = littleTip else {
            // If there were no observations for more than 2 seconds, reset gesture processor.
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                
            }
            // Clear the UI
            showPoints([], color: .clear)
            return
        }
        
        // Unwrap the previewLayer safely
        guard let previewLayer = previewLayer else {
            print("Preview layer is not available")
            return
        }
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        let middlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: middlePoint)
        let ringPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: ringPoint)
        let littlePointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: littlePoint)
        
        
        // Update the UI with the finger tip points
        showPoints([thumbPointConverted, indexPointConverted, middlePointConverted, ringPointConverted, littlePointConverted], color: selectedColor)
        
        // Draw photo on the rounded rectangles
        if let photo = selectedPhoto {
            showPhoto(photo, at: thumbPointConverted, forFinger: "thumb")
            showPhoto(photo, at: indexPointConverted, forFinger: "index")
            showPhoto(photo, at: middlePointConverted, forFinger: "middle")
            showPhoto(photo, at: ringPointConverted, forFinger: "ring")
            showPhoto(photo, at: littlePointConverted, forFinger: "little")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Process finger tip points
                self.showPoints([thumbPointConverted, indexPointConverted, middlePointConverted, ringPointConverted, littlePointConverted], color: selectedColor)
            }

        }

    }
    private func updatePhotoSize(_ size: CGSize) {
            photoSize = size
        }

    private func showPoints(_ points: [CGPoint], color: UIColor) {
        // Remove existing sublayers from drawOverlay
        drawOverlay.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Draw rounded rectangles at each point
        for point in points {
            drawRoundedRectangle(at: point, color: color, photoSize: photoSize)
        }
    }

    private var thumbImageView: UIImageView?
    private var indexImageView: UIImageView?
    private var middleImageView: UIImageView?
    private var ringImageView: UIImageView?
    private var littleImageView: UIImageView?

    public func showPhoto(_ photo: UIImage?, at point: CGPoint, forFinger finger: String) {
        guard let photo = photo else { return }
        
        var imageView: UIImageView?

        switch finger {
        case "thumb":
            imageView = thumbImageView ?? UIImageView()
            thumbImageView = imageView
        case "index":
            imageView = indexImageView ?? UIImageView()
            indexImageView = imageView
        case "middle":
            imageView = middleImageView ?? UIImageView()
            middleImageView = imageView
        case "ring":
            imageView = ringImageView ?? UIImageView()
            ringImageView = imageView
        case "little":
            imageView = littleImageView ?? UIImageView()
            littleImageView = imageView
        default:
            return
        }

        // Resize the image to a smaller size
        let resizedPhoto = resizeImage(photo, to: CGSize(width: 20, height: 40))
        imageView?.image = resizedPhoto
        imageView?.frame = CGRect(x: point.x - resizedPhoto.size.width / 2, y: point.y - resizedPhoto.size.height / 2, width: resizedPhoto.size.width, height: resizedPhoto.size.height)
        

        // Apply oval-shaped mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(ovalIn: imageView?.bounds ?? CGRect.zero).cgPath
        imageView?.layer.mask = maskLayer

        imageView?.contentMode = .scaleAspectFill
        addSubview(imageView ?? UIImageView())
    }



    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? image
    }
// MARK: Capture output ( also another hard part )
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            let middleFingerPoints = try observation.recognizedPoints(.middleFinger)
            let ringFingerPoints = try observation.recognizedPoints(.ringFinger)
            let littleFingerPoints = try observation.recognizedPoints(.littleFinger)
            
            guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.indexTip],
                let middleTipPoint = middleFingerPoints[.middleTip], let ringTipPoint = ringFingerPoints[.ringTip],
                let littleTipPoint = littleFingerPoints[.littleTip] else {
                    return
            }
            
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 &&
                middleTipPoint.confidence > 0.3 && ringTipPoint.confidence > 0.3 &&
                littleTipPoint.confidence > 0.3 else {
                    return
            }
            
            let thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            let indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
            let middleTip = CGPoint(x: middleTipPoint.location.x, y: 1 - middleTipPoint.location.y)
            let ringTip = CGPoint(x: ringTipPoint.location.x, y: 1 - ringTipPoint.location.y)
            let littleTip = CGPoint(x: littleTipPoint.location.x, y: 1 - littleTipPoint.location.y)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Process finger tip points
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, littleTip: littleTip)
            }
            
        } catch {
            cameraSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.displayError(error)
            }
        }
    }
    // called rounded rectangle but I make it a bit more oval, I like oval shape on my nails :P
    private func drawRoundedRectangle(at point: CGPoint, color: UIColor?, photoSize: CGSize) {
        let rectangleWidth = photoSize.width + 16 // Add some padding for better visibility
        let rectangleHeight = photoSize.height + 30 // Increase height for a longer oval shape
        let rect = CGRect(x: point.x - rectangleWidth / 2, y: point.y - rectangleHeight / 2, width: rectangleWidth, height: rectangleHeight)
        
        // Creating custom path for a more pointy top end
        let roundedRectPath = UIBezierPath()
        roundedRectPath.move(to: CGPoint(x: rect.minX + 10, y: rect.minY))
        roundedRectPath.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.minY))
        roundedRectPath.addArc(withCenter: CGPoint(x: rect.maxX - 10, y: rect.minY + 10), radius: 10, startAngle: CGFloat(3 * Double.pi / 2), endAngle: 0, clockwise: true)
        roundedRectPath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 10))
        roundedRectPath.addArc(withCenter: CGPoint(x: rect.maxX - 10, y: rect.maxY - 10), radius: 10, startAngle: 0, endAngle: CGFloat(Double.pi / 2), clockwise: true)
        roundedRectPath.addLine(to: CGPoint(x: rect.minX + 10, y: rect.maxY))
        roundedRectPath.addArc(withCenter: CGPoint(x: rect.minX + 10, y: rect.maxY - 10), radius: 10, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
        roundedRectPath.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 10))
        roundedRectPath.addArc(withCenter: CGPoint(x: rect.minX + 10, y: rect.minY + 10), radius: 10, startAngle: CGFloat(Double.pi), endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
        roundedRectPath.close()

        let roundedRectLayer = CAShapeLayer()
        roundedRectLayer.path = roundedRectPath.cgPath
        if let color = color {
            roundedRectLayer.strokeColor = color.cgColor
            roundedRectLayer.fillColor = color.cgColor
        } else {
            roundedRectLayer.strokeColor = UIColor.clear.cgColor
            roundedRectLayer.fillColor = UIColor.clear.cgColor
        }
        drawOverlay.addSublayer(roundedRectLayer)
    }

    
    // Various options for color try-on
    private func setupColorOptions() {
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(scrollView)
            
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
            scrollView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            colorButtonsStackView = UIStackView()
            colorButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
            colorButtonsStackView.axis = .horizontal
            colorButtonsStackView.alignment = .center
            colorButtonsStackView.distribution = .equalSpacing
            colorButtonsStackView.spacing = 5
            scrollView.addSubview(colorButtonsStackView)
            
            colorButtonsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            colorButtonsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            colorButtonsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            colorButtonsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            colorButtonsStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true // Ensure stack view height matches scroll view height
            
            for (red, green, blue) in colorOptions {
                let button = UIButton()
                button.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                button.layer.cornerRadius = 5
                button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
                button.setTitle(nil, for: .normal) // Remove title
                colorButtonsStackView.addArrangedSubview(button)
                button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true // Square buttons
            }
        }
    

    @objc private func colorButtonTapped(_ sender: UIButton) {
        guard let colorIndex = colorButtonsStackView.arrangedSubviews.firstIndex(of: sender) else {
            return
        }
        let (red, green, blue) = colorOptions[colorIndex]
        let newSelectedColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        // Update selectedColor
        selectedColor = newSelectedColor
        selectedPhoto = nil
        
        // Reset the photo on the rounded rectangles to nil
        updateRoundedRectanglePhotos(nil)
        
        // Resetting the points to trigger the display with the new color
        processPoints(thumbTip: nil, indexTip: nil, middleTip: nil, ringTip: nil, littleTip: nil)
    }

    private func setupPhotoButtons() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        photoButtonsStackView = UIStackView()
        photoButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        photoButtonsStackView.axis = .horizontal
        photoButtonsStackView.alignment = .center
        photoButtonsStackView.distribution = .equalSpacing
        photoButtonsStackView.spacing = 5
        scrollView.addSubview(photoButtonsStackView)
        
        photoButtonsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        photoButtonsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10).isActive = true
        photoButtonsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        photoButtonsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        photoButtonsStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true // Adjust bottom anchor to give space for photo buttons
        scrollView.heightAnchor.constraint(equalToConstant: 50).isActive = true // Set a fixed height for the scroll view
        
        // Populate photoImages array
        photoImages = [
            UIImage(named: "photo1")!,
            UIImage(named: "photo2")!,
            UIImage(named: "photo3")!,
            UIImage(named: "photo4")!,
            UIImage(named: "photo5")!,
            UIImage(named: "photo6")!,
            UIImage(named: "photo7")!,
            UIImage(named: "photo8")!,
            UIImage(named: "photo10")!,
            UIImage(named: "photo9")!,
          
        ]
        
        for image in photoImages {
            let button = UIButton()
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.addTarget(self, action: #selector(photoButtonTapped(_:)), for: .touchUpInside)
            photoButtonsStackView.addArrangedSubview(button)
            button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true // Square buttons
        }
    }

    private var thumbTipPoint: CGPoint?
        private var indexTipPoint: CGPoint?
        private var middleTipPoint: CGPoint?
        private var ringTipPoint: CGPoint?
        private var littleTipPoint: CGPoint?

    @objc private func photoButtonTapped(_ sender: UIButton) {
        guard let photoIndex = photoButtonsStackView.arrangedSubviews.firstIndex(of: sender) else {
            return
        }
        
        // Update the image of the previously selected button
        if let previousButton = photoButtonsStackView.arrangedSubviews.compactMap({ $0 as? UIButton }).first(where: { $0 != sender }),
           let previousIndex = photoButtonsStackView.arrangedSubviews.firstIndex(of: previousButton) {
            let previousImage = photoImages[previousIndex]
            previousButton.setImage(previousImage, for: .normal)
        }

        // Update selectedPhoto
        selectedPhoto = photoImages[photoIndex]
        
        // Update the button image with the selected photo
        sender.setImage(selectedPhoto, for: .normal)

        // Update the photo size
        updatePhotoSize(selectedPhoto?.size ?? .zero)
        
        // Hide the rounded rectangles by updating the photo size to zero
        updatePhotoSize(.zero)
        
        // Update the finger tip points with the new photo positions
        processPoints(thumbTip: thumbTipPoint, indexTip: indexTipPoint, middleTip: middleTipPoint, ringTip: ringTipPoint, littleTip: littleTipPoint)
        
        // Update the photo on the rounded rectangles
        updateRoundedRectanglePhotos(selectedPhoto)
    }

    private func updateRoundedRectanglePhotos(_ photo: UIImage?) {
        thumbImageView?.image = photo
        indexImageView?.image = photo
        middleImageView?.image = photo
        ringImageView?.image = photo
        littleImageView?.image = photo
    }

    private func displayError(_ error: Error) {
        if let parentViewController = parentViewController {
            AppError.display(error, inViewController: parentViewController)
        } else {
            print("Error: \(error.localizedDescription)")
        }
    }
}
