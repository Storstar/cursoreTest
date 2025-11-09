import SwiftUI
import UIKit

struct CarSelectionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @State private var selectedCar: Car?
    @State private var showAddCar = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // Премиальный градиентный фон
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color(red: 0.98, green: 0.99, blue: 1.0),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Text("Выберите автомобиль")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Выберите или добавьте автомобиль для начала работы")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    
                    // Горизонтальный скролл автомобилей
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 24) {
                            // Карточки автомобилей
                            ForEach(carViewModel.cars, id: \.objectID) { car in
                                CarAvatarCard(
                                    car: car,
                                    isSelected: selectedCar?.objectID == car.objectID,
                                    onTap: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            selectedCar = car
                                        }
                                    }
                                )
                            }
                            
                            // Кнопка добавления нового авто
                            AddCarCard(onTap: {
                                showAddCar = true
                            })
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 20)
                    }
                    
                    Spacer()
                    
                    // Кнопка "Продолжить"
                    if let car = selectedCar {
                        Button(action: {
                            carViewModel.selectCar(car)
                            navigationPath.append("main")
                        }) {
                            HStack(spacing: 12) {
                                Text("Продолжить")
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else if carViewModel.cars.isEmpty {
                        // Кнопка "Добавить первый автомобиль"
                        Button(action: {
                            showAddCar = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Добавить автомобиль")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "main" {
                    MainTabView()
                }
            }
            .sheet(isPresented: $showAddCar) {
                CarInputView(navigationPath: $navigationPath)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled(false) // Разрешаем свайп вниз для закрытия
            }
            .onAppear {
                if let user = authViewModel.currentUser {
                    carViewModel.loadCars(for: user)
                }
            }
        }
    }
}

// Круглая карточка автомобиля
struct CarAvatarCard: View {
    let car: Car
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Круглый аватар
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                    onTap()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
            }) {
                ZStack {
                    // Фон с градиентом
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected 
                                    ? [Color.blue.opacity(0.8), Color.blue.opacity(0.6)]
                                    : [Color.blue.opacity(0.3), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .overlay(
                            Circle()
                                .stroke(
                                    isSelected ? Color.blue : Color.clear,
                                    lineWidth: isSelected ? 4 : 0
                                )
                        )
                        .shadow(
                            color: isSelected 
                                ? .blue.opacity(0.4) 
                                : .black.opacity(0.1),
                            radius: isSelected ? 20 : 10,
                            x: 0,
                            y: isSelected ? 10 : 5
                        )
                        .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
                    
                    // Фото или иконка авто
                    Group {
                        if let photoData = car.photoData,
                           let image = UIImage(data: photoData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "car.fill")
                                .font(.system(size: 50, weight: .medium))
                                .foregroundColor(isSelected ? .white : .blue.opacity(0.7))
                        }
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Название авто
            VStack(spacing: 4) {
                Text("\(car.brand ?? "") \(car.model ?? "")")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(car.year)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .frame(width: 140)
        }
    }
}

// Кнопка добавления нового авто
struct AddCarCard: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                    onTap()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .overlay(
                            Circle()
                                .stroke(
                                    Color.gray.opacity(0.3),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [8, 4])
                                )
                        )
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundColor(.blue.opacity(0.6))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(spacing: 4) {
                Text("Добавить авто")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("Новый")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .frame(width: 140)
        }
    }
}

