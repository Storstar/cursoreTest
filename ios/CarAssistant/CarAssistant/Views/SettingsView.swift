import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var carViewModel: CarViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var systemColorScheme
    @State private var showAddCar = false
    @State private var editingCar: Car?
    @StateObject private var locationManager = LocationManager()
    @State private var isLocationAuthorized = false
    @State private var isLocationUpdated = false
    @State private var isLocationLoading = false
    @State private var loadingTimeoutTask: DispatchWorkItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Градиентный фон приложения (авто ассистент)
                appGradientBackground
                    .ignoresSafeArea()
                
                List {
                // Список автомобилей
                Section(header: Text(Localization.Settings.myCars)) {
                    if carViewModel.cars.isEmpty {
                        Text(Localization.Settings.noCars)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(carViewModel.cars, id: \.objectID) { car in
                            carRow(car: car)
                        }
                    }
                    
                    addCarButton
                }
                
                // Геопозиция
                Section(header: Text(Localization.Settings.geolocation)) {
                    HStack {
                        Image(systemName: isLocationAuthorized ? "location.fill" : "location.circle")
                            .foregroundColor(isLocationAuthorized ? .blue : .secondary)
                        Text(Localization.Settings.autoDetermined)
                            .foregroundColor(.secondary)
                        
                        if isLocationUpdated {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    Button(action: {
                        // Сбрасываем галочку и показываем индикатор загрузки
                        isLocationUpdated = false
                        isLocationLoading = true
                        
                        // Отменяем предыдущий таймаут, если он был
                        loadingTimeoutTask?.cancel()
                        
                        // Устанавливаем таймаут для индикатора загрузки (30 секунд)
                        let timeoutWork = DispatchWorkItem {
                            if isLocationLoading {
                                isLocationLoading = false
                                print("Таймаут определения геопозиции")
                            }
                        }
                        loadingTimeoutTask = timeoutWork
                        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutWork)
                        
                        locationManager.requestLocation()
                    }) {
                        HStack {
                            if isLocationLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "location.circle.fill")
                            }
                            Text(isLocationLoading ? Localization.Settings.determining : Localization.Settings.determineLocation)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
                
                // Внешний вид
                Section(header: Text(Localization.Settings.appearance)) {
                    HStack {
                        Image(systemName: themeManager.colorScheme == .dark ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(.blue)
                        Text(Localization.Settings.theme)
                        
                        Spacer()
                        
                        Picker("", selection: Binding(
                            get: {
                                if themeManager.colorScheme == .dark {
                                    return "dark"
                                } else {
                                    return "light"
                                }
                            },
                            set: { newValue in
                                if newValue == "dark" {
                                    themeManager.setDarkTheme()
                                } else {
                                    themeManager.setLightTheme()
                                }
                            }
                        )) {
                            Text(Localization.Settings.lightTheme).tag("light")
                            Text(Localization.Settings.darkTheme).tag("dark")
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        Text(Localization.Settings.language)
                        
                        Spacer()
                        
                        Picker("", selection: Binding(
                            get: { languageManager.currentLanguage },
                            set: { newValue in
                                languageManager.setLanguage(newValue)
                            }
                        )) {
                            ForEach(LanguageManager.AppLanguage.allCases, id: \.self) { language in
                                Text(language.nativeName).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // Аккаунт
                Section(header: Text(Localization.Settings.account)) {
                    Button(role: .destructive, action: {
                        print("🔴 Logout button tapped")
                        authViewModel.logout()
                        print("🔴 Logout completed. isAuthenticated: \(authViewModel.isAuthenticated)")
                    }) {
                        HStack {
                            Text(Localization.Settings.logout)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(Localization.Settings.profile)
            .scrollDismissesKeyboard(.interactively)
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
                    // Загружаем автомобили только если они еще не загружены
                    // ContentView уже загружает их при старте
                    if carViewModel.cars.isEmpty {
                        await carViewModel.loadCarsAsync(for: user)
                    }
                    // Автоматически определяем геопозицию при открытии приложения
                    locationManager.requestLocation()
                }
            }
            .onChange(of: locationManager.fullAddress) { newValue in
                // Сохраняем полный адрес в Core Data, когда он становится доступен
                if let user = authViewModel.currentUser, let fullAddress = newValue {
                    user.fullAddress = fullAddress
                    CoreDataManager.shared.save()
                }
            }
            .onChange(of: locationManager.city) { newValue in
                // Если newValue == nil, значит произошла ошибка - скрываем индикатор загрузки
                guard let newValue = newValue else {
                    // Отменяем таймаут
                    loadingTimeoutTask?.cancel()
                    loadingTimeoutTask = nil
                    isLocationLoading = false
                    return
                }
                // Автоматически сохраняем город в Core Data
                if let user = authViewModel.currentUser {
                    user.city = newValue
                    CoreDataManager.shared.save()
                    // Отменяем таймаут и скрываем индикатор загрузки
                    loadingTimeoutTask?.cancel()
                    loadingTimeoutTask = nil
                    isLocationLoading = false
                    // Всегда показываем галочку при успешном обновлении (даже при повторном нажатии)
                    // Сначала сбрасываем, чтобы анимация сработала
                    isLocationUpdated = false
                    // Небольшая задержка для сброса, затем показываем галочку
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isLocationUpdated = true
                        }
                        // Скрываем галочку через 3 секунды
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isLocationUpdated = false
                            }
                        }
                    }
                }
            }
            .onChange(of: locationManager.country) { newValue in
                // Если newValue == nil, значит произошла ошибка - скрываем индикатор загрузки
                guard let newValue = newValue else {
                    // Отменяем таймаут
                    loadingTimeoutTask?.cancel()
                    loadingTimeoutTask = nil
                    if isLocationLoading {
                        isLocationLoading = false
                    }
                    return
                }
                // Автоматически сохраняем страну в Core Data
                if let user = authViewModel.currentUser {
                    user.country = newValue
                    CoreDataManager.shared.save()
                    // Отменяем таймаут и скрываем индикатор загрузки (если еще не скрыт)
                    loadingTimeoutTask?.cancel()
                    loadingTimeoutTask = nil
                    if isLocationLoading {
                        isLocationLoading = false
                    }
                    // Всегда показываем галочку при успешном обновлении (даже при повторном нажатии)
                    // Если галочка еще не показана, показываем ее
                    if !isLocationUpdated {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isLocationUpdated = true
                        }
                        // Скрываем галочку через 3 секунды
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isLocationUpdated = false
                            }
                        }
                    }
                }
            }
            .onChange(of: locationManager.isAuthorized) { newValue in
                isLocationAuthorized = newValue
                // Если авторизация отозвана, скрываем индикатор загрузки
                if !newValue {
                    // Отменяем таймаут
                    loadingTimeoutTask?.cancel()
                    loadingTimeoutTask = nil
                    isLocationLoading = false
                }
            }
            .onDisappear {
                // Останавливаем LocationManager при закрытии экрана для экономии памяти
                locationManager.stop()
                // Отменяем все таймауты
                loadingTimeoutTask?.cancel()
                loadingTimeoutTask = nil
            }
            }
            .scrollContentBackground(.hidden) // Скрываем фон List, чтобы был виден градиент
        }
    }
    
    /// Градиентный фон приложения (авто ассистент)
    private var appGradientBackground: some View {
        let isDark = themeManager.colorScheme == .dark || (themeManager.colorScheme == nil && systemColorScheme == .dark)
        
        return LinearGradient(
            colors: isDark ? [
                Color(red: 0.15, green: 0.17, blue: 0.20),      // Темно-синий (верх)
                Color(red: 0.12, green: 0.15, blue: 0.18),    // Темно-серо-синий (середина)
                Color(red: 0.10, green: 0.12, blue: 0.15)     // Темно-серый (низ)
            ] : [
                Color(red: 0.95, green: 0.97, blue: 1.0),      // Светло-голубой (верх)
                Color(red: 0.92, green: 0.95, blue: 0.98),    // Светло-серо-голубой (середина)
                Color(red: 0.88, green: 0.92, blue: 0.96)     // Светло-серый (низ)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func carRow(car: Car) -> some View {
        let isDefault = carViewModel.car?.objectID == car.objectID
        
        CarManagementCard(
            car: car,
            isDefault: isDefault,
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
            editingCar = car
        }
        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                editingCar = car
            } label: {
                Label(Localization.Common.edit, systemImage: "pencil")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                deleteCar(car)
            } label: {
                Label(Localization.Common.delete, systemImage: "trash")
            }
        }
    }
    
    private var addCarButton: some View {
        HStack {
            Spacer()
            Button {
                showAddCar = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text(Localization.Settings.addCar)
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
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
        .listRowBackground(Color.clear)
    }
    
    private func deleteCar(_ car: Car) {
        guard let user = authViewModel.currentUser else { return }
        
        // Безопасное удаление с обработкой ошибок
        carViewModel.deleteCar(car, for: user)
    }
    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - LocationManager

// LocationManager для определения геопозиции
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var city: String?
    @Published var country: String?
    @Published var street: String?
    @Published var postalCode: String?
    @Published var administrativeArea: String? // Регион/область
    @Published var subAdministrativeArea: String? // Район
    @Published var fullAddress: String? // Полный адрес для использования ИИ
    @Published var isAuthorized = false
    private var locationRequestTimeout: DispatchWorkItem?
    private var currentGeocoder: CLGeocoder?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkAuthorization()
        
        // Подписываемся на уведомление о переходе в фон
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: NSNotification.Name("AppDidEnterBackground"),
            object: nil
        )
    }
    
    @objc private func handleAppDidEnterBackground() {
        // Останавливаем все операции при переходе в фон
        stop()
    }
    
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            // Не запрашиваем геопозицию автоматически - только при явном вызове requestLocation()
        case .notDetermined:
            isAuthorized = false
        default:
            isAuthorized = false
        }
    }
    
    func requestLocation() {
        // Отменяем предыдущий таймаут, если он был
        locationRequestTimeout?.cancel()
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            // Сбрасываем предыдущие значения перед новым запросом
            city = nil
            country = nil
            street = nil
            postalCode = nil
            administrativeArea = nil
            subAdministrativeArea = nil
            fullAddress = nil
            
            // Устанавливаем таймаут для получения местоположения (15 секунд)
            let timeoutWork = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                // Проверяем, получили ли мы местоположение
                // Если city и country все еще nil, значит таймаут
                if self.city == nil && self.country == nil {
                    print("Таймаут получения местоположения")
                    // Уведомляем об ошибке через Published свойство
                    self.city = nil
                    self.country = nil
                    self.street = nil
                    self.postalCode = nil
                    self.administrativeArea = nil
                    self.subAdministrativeArea = nil
                    self.fullAddress = nil
                }
            }
            locationRequestTimeout = timeoutWork
            DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: timeoutWork)
            
            locationManager.requestLocation()
        default:
            isAuthorized = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Отменяем таймаут получения местоположения, так как мы получили местоположение
        locationRequestTimeout?.cancel()
        locationRequestTimeout = nil
        
        // Отменяем предыдущий геокодер, если он есть
        currentGeocoder?.cancelGeocode()
        
        let geocoder = CLGeocoder()
        currentGeocoder = geocoder
        
        // Устанавливаем таймаут для геокодирования (10 секунд)
        var geocodingCompleted = false
        var timeoutWork: DispatchWorkItem?
        timeoutWork = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if !geocodingCompleted {
                geocodingCompleted = true
                geocoder.cancelGeocode()
                DispatchQueue.main.async {
                    print("Таймаут геокодирования")
                    self.city = nil
                    self.country = nil
                    self.street = nil
                    self.postalCode = nil
                    self.administrativeArea = nil
                    self.subAdministrativeArea = nil
                    self.fullAddress = nil
                    self.currentGeocoder = nil
                }
            }
        }
        if let timeout = timeoutWork {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeout)
        }
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            guard !geocodingCompleted else { return }
            geocodingCompleted = true
            timeoutWork?.cancel()
            self.currentGeocoder = nil
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    // Уведомляем об ошибке через Published свойство (nil означает ошибку)
                    self.city = nil
                    self.country = nil
                    self.street = nil
                    self.postalCode = nil
                    self.administrativeArea = nil
                    self.subAdministrativeArea = nil
                    self.fullAddress = nil
                    return
                }
                guard let placemark = placemarks?.first else {
                    // Уведомляем об ошибке через Published свойство
                    self.city = nil
                    self.country = nil
                    self.street = nil
                    self.postalCode = nil
                    self.administrativeArea = nil
                    self.subAdministrativeArea = nil
                    self.fullAddress = nil
                    return
                }
                // Сохраняем все данные об адресе
                self.city = placemark.locality
                self.country = placemark.country
                self.street = placemark.thoroughfare // Улица
                self.postalCode = placemark.postalCode // Почтовый индекс
                self.administrativeArea = placemark.administrativeArea // Регион/область
                self.subAdministrativeArea = placemark.subAdministrativeArea // Район
                
                // Формируем полный адрес для использования ИИ
                var addressComponents: [String] = []
                if let street = placemark.thoroughfare {
                    addressComponents.append(street)
                }
                if let subLocality = placemark.subLocality {
                    addressComponents.append(subLocality)
                }
                if let locality = placemark.locality {
                    addressComponents.append(locality)
                }
                if let administrativeArea = placemark.administrativeArea {
                    addressComponents.append(administrativeArea)
                }
                if let postalCode = placemark.postalCode {
                    addressComponents.append(postalCode)
                }
                if let country = placemark.country {
                    addressComponents.append(country)
                }
                
                self.fullAddress = addressComponents.isEmpty ? nil : addressComponents.joined(separator: ", ")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        // Отменяем таймаут получения местоположения
        locationRequestTimeout?.cancel()
        locationRequestTimeout = nil
        
        DispatchQueue.main.async {
            self.isAuthorized = false
            // Уведомляем об ошибке через Published свойство
            self.city = nil
            self.country = nil
            self.street = nil
            self.postalCode = nil
            self.administrativeArea = nil
            self.subAdministrativeArea = nil
            self.fullAddress = nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
    }
    
    /// Остановить все операции LocationManager для экономии памяти
    func stop() {
        // Отменяем все таймауты
        locationRequestTimeout?.cancel()
        locationRequestTimeout = nil
        
        // Отменяем геокодирование
        currentGeocoder?.cancelGeocode()
        currentGeocoder = nil
        
        // Останавливаем обновления местоположения
        locationManager.stopUpdatingLocation()
        
        // Очищаем все данные
        city = nil
        country = nil
        street = nil
        postalCode = nil
        administrativeArea = nil
        subAdministrativeArea = nil
        fullAddress = nil
    }
    
    deinit {
        // Убеждаемся, что все ресурсы освобождены
        NotificationCenter.default.removeObserver(self)
        stop()
    }
}
