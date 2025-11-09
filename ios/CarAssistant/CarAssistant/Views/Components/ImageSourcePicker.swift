import SwiftUI

struct ImageSourcePicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    @Binding var showPhotoPicker: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Сделать фото") {
                showImagePicker = true
                dismiss()
            }
            .padding()
            
            Button("Выбрать из галереи") {
                showPhotoPicker = true
                dismiss()
            }
            .padding()
            
            Button("Отмена") {
                dismiss()
            }
            .padding()
        }
    }
}

