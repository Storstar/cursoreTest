import SwiftUI
import UIKit

struct CarSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var carViewModel: CarViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.97, blue: 0.99),
                        Color(red: 0.98, green: 0.99, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(carViewModel.cars, id: \.objectID) { car in
                            Button(action: {
                                carViewModel.selectCar(car)
                                dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    Group {
                                        // Используем thumbnail для экономии памяти (60x60 = 120pt на retina = 240px)
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
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(car.brand ?? "") \(car.model ?? "")")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("\(car.year) • \(car.engine ?? "")")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if carViewModel.car?.objectID == car.objectID {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.9),
                                                    Color(red: 0.98, green: 0.98, blue: 0.99).opacity(0.9)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Выбрать автомобиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

