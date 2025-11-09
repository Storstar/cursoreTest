import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @State private var showAddCar = false
    @State private var editingCar: Car?
    @StateObject private var locationManager = LocationManager()
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var isLocationAuthorized = false
    
    var body: some View {
        NavigationStack {
            List {
                // Список автомобилей
                Section(header: Text("Мои автомобили")) {
                    if carViewModel.cars.isEmpty {
                        Text("Нет сохранённых автомобилей")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(carViewModel.cars, id: \.objectID) { car in
                            CarManagementCard(
                                car: car,
                                isDefault: carViewModel.car?.objectID == car.objectID,
                                onSetDefault: {
                                    carViewModel.selectCar(car)
                                },
                                onEdit: {
                                    editingCar = car
                                },
                                onDelete: {
                                    deleteCar(car)
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Тап по карточке открывает редактирование
                                editingCar = car
                            }
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    editingCar = car
                                } label: {
                                    Label("Редактировать", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteCar(car)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    // Кнопка "Добавить авто"
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddCar = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Добавить авто")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.1))
                            )
                        }
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                
                // Геопозиция
                Section(header: Text("Геопозиция")) {
                    if isLocationAuthorized {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Автоматически определено")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Button(action: {
                            locationManager.requestLocation()
                        }) {
                            HStack {
                                Image(systemName: "location.circle")
                                Text("Определить местоположение")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    TextField("Страна", text: $country)
                        .onChange(of: country) { _ in
                            saveLocation()
                        }
                    
                    TextField("Город", text: $city)
                        .onChange(of: city) { _ in
                            saveLocation()
                        }
                }
                
                // Аккаунт
                Section(header: Text("Аккаунт")) {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("Выйти")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Профиль")
            .sheet(isPresented: $showAddCar) {
                CarInputView(navigationPath: .constant(NavigationPath()))
                    .environmentObject(authViewModel)
                    .environmentObject(carViewModel)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled(false) // Разрешаем свайп вниз для закрытия
                    .onDisappear {
                        if let user = authViewModel.currentUser {
                            carViewModel.loadCars(for: user)
                        }
                    }
            }
            .sheet(item: Binding(
                get: { editingCar },
                set: { editingCar = $0 }
            )) { (car: Car) in
                CarEditView(car: car)
                    .environmentObject(authViewModel)
                    .environmentObject(carViewModel)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled(false) // Разрешаем свайп вниз для закрытия
            }
            .task {
                if let user = authViewModel.currentUser {
                    await carViewModel.loadCarsAsync(for: user)
                    loadUserLocation(user: user)
                }
            }
            .onChange(of: locationManager.city) { newValue in
                if let newValue = newValue {
                    city = newValue
                    saveLocation()
                }
            }
            .onChange(of: locationManager.country) { newValue in
                if let newValue = newValue {
                    country = newValue
                    saveLocation()
                }
            }
            .onChange(of: locationManager.isAuthorized) { newValue in
                isLocationAuthorized = newValue
            }
            // УБРАНО .refreshable - чтобы не мешать свайпу вниз для закрытия sheet'ов добавления/редактирования авто
        }
    }
    
    private func deleteCar(_ car: Car) {
        guard let user = authViewModel.currentUser else { return }
        
        // Безопасное удаление с обработкой ошибок
        carViewModel.deleteCar(car, for: user)
    }
    
    private func loadUserLocation(user: User) {
        city = user.city ?? ""
        country = user.country ?? ""
        isLocationAuthorized = locationManager.isAuthorized
    }
    
    private func saveLocation() {
        guard let user = authViewModel.currentUser else { return }
        user.city = city.isEmpty ? nil : city
        user.country = country.isEmpty ? nil : country
        CoreDataManager.shared.save()
    }
}

// LocationManager для определения геопозиции
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var city: String?
    @Published var country: String?
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkAuthorization()
    }
    
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            locationManager.requestLocation()
        case .notDetermined:
            isAuthorized = false
        default:
            isAuthorized = false
        }
    }
    
    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            locationManager.requestLocation()
        default:
            isAuthorized = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first else { return }
            DispatchQueue.main.async {
                self.city = placemark.locality
                self.country = placemark.country
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }
}
