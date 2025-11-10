import SwiftUI

struct ImageSourcePicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    @Binding var showPhotoPicker: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Плашка в центре экрана
            VStack(spacing: 0) {
                // Кнопка "Сделать фото"
                Button(action: {
                    showImagePicker = true
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        Text("Сделать фото")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.leading, 20)
                
                // Кнопка "Выбрать из галереи"
                Button(action: {
                    showPhotoPicker = true
                    onDismiss()
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        Text("Выбрать из галереи")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
                .buttonStyle(PlainButtonStyle())
                
                Divider()
                    .padding(.leading, 20)
                
                // Кнопка "Отмена"
                Button(action: {
                    onDismiss()
                }) {
                    Text("Отмена")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.systemBackground))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 280)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
    }
}

