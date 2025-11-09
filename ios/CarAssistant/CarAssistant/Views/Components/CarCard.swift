import SwiftUI
import UIKit

struct CarCard: View {
    let car: Car
    let onEditTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Фото автомобиля
            ZStack(alignment: .topTrailing) {
                // Placeholder изображение (TODO: заменить на реальное фото из Assets или загруженное пользователем)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                    .overlay(
                        Group {
                            if let photoData = car.photoData,
                               let image = UIImage(data: photoData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                            } else {
                                Image(systemName: "car.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    )
                    // TODO: Добавить поддержку загруженных пользователем фото
                    // TODO: Добавить placeholder изображения по марке/модели из Assets
                
                // Кнопка "Сменить авто"
                Button(action: onEditTap) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.circle.fill")
                        Text("Сменить авто")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(16)
            }
            
            // Информация об автомобиле
            VStack(alignment: .leading, spacing: 8) {
                // Название авто
                Text("\(car.brand ?? "") \(car.model ?? "")")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // Год выпуска
                Text("\(car.year)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
}

