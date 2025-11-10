import SwiftUI
import UIKit

struct CarMiniCard: View {
    let car: Car
    let onChangeCarTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Фото авто
            // Используем thumbnail для экономии памяти (60x60 = 120pt на retina = 240px)
            Group {
                if let photoData = car.photoData,
                   let thumbnail = ImageOptimizer.createThumbnail(from: photoData, maxSize: 120) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
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
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "car.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.blue.opacity(0.2), radius: 10, x: 0, y: 5)
            
            // Информация об авто (марка, модель и год)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(car.brand ?? "") \(car.model ?? "")")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(car.year)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Кнопка смены авто
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                    onChangeCarTap()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
            }) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        )
    }
}

