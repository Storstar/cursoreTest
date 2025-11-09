import SwiftUI
import UIKit

struct CarPhotoView: View {
    let car: Car
    let size: CGFloat
    
    init(car: Car, size: CGFloat = 60) {
        self.car = car
        self.size = size
    }
    
    var body: some View {
        Group {
            if let photoData = car.photoData,
               let image = UIImage(data: photoData) {
                // Создаем thumbnail для уменьшения использования памяти
                let thumbnail = ImageOptimizer.shared.createThumbnail(from: image, maxSize: size * 2) ?? image
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                    .drawingGroup() // Оптимизация рендеринга для уменьшения использования памяти
            } else {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)
                    
                    Image(systemName: "car.fill")
                        .font(.system(size: size * 0.47, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

