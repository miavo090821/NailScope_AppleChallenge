import SwiftUI
// MARK: Image picker for the Photo Gallery 
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isVisible: Bool
    @Binding var selectedImage: UIImage?
    var sourceType: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(isVisible: $isVisible, selectedImage: $selectedImage)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.allowsEditing = true
        vc.sourceType = sourceType == 1 ? .photoLibrary : .camera
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var isVisible: Bool
        @Binding var selectedImage: UIImage?

        init(isVisible: Binding<Bool>, selectedImage: Binding<UIImage?>) {
            _isVisible = isVisible
            _selectedImage = selectedImage
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                selectedImage = originalImage
            }

            isVisible = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isVisible = false
        }
    }
}
