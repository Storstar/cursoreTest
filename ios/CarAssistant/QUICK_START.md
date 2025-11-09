# Быстрый старт

## Создайте проект в Xcode (5 минут)

1. **Откройте Xcode**

2. **File → New → Project**

3. **Выберите:**
   - iOS → App
   - Нажмите Next

4. **Заполните:**
   - Product Name: **CarAssistant**
   - Team: Ваша команда
   - Organization Identifier: **com.carassistant**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - **НЕ выбирайте Core Data!**
   - Нажмите Next

5. **Выберите папку:**
   - `/Users/nikitastarozilov/cursoreTest/ios/CarAssistant`
   - Нажмите Create

6. **Удалите созданные файлы:**
   - Удалите `ContentView.swift` (если создан)
   - Удалите `CarAssistantApp.swift` (если создан)

7. **Добавьте все файлы:**
   - Правой кнопкой на папку `CarAssistant` → **Add Files to "CarAssistant"**
   - Выберите папку `CarAssistant` (внутри `ios/CarAssistant`)
   - ✅ "Create groups"
   - ✅ "Add to targets: CarAssistant"
   - Нажмите **Add**

8. **Добавьте Core Data модель:**
   - Правой кнопкой на папку `CarAssistant` → **Add Files to "CarAssistant"**
   - Выберите `CarAssistant.xcdatamodeld`
   - ✅ "Add to targets: CarAssistant"
   - Нажмите **Add**

9. **Настройте модель данных:**
   - Выберите `CarAssistant.xcdatamodeld` в навигаторе
   - В File Inspector (правая панель):
     - Code Generation: **Manual/None**
     - Target Membership: ✅ **CarAssistant**

10. **Соберите проект:**
    - Product → Clean Build Folder (`Cmd+Shift+K`)
    - Product → Build (`Cmd+B`)

## Готово! ✅

Все файлы созданы и готовы к работе. Просто создайте проект в Xcode и добавьте файлы.

