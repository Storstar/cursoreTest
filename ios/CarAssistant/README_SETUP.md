# Инструкция по созданию проекта в Xcode

## Шаг 1: Создайте новый проект в Xcode

1. Откройте Xcode
2. File → New → Project
3. Выберите "iOS" → "App"
4. Нажмите Next
5. Заполните:
   - Product Name: CarAssistant
   - Team: Ваша команда
   - Organization Identifier: com.carassistant
   - Interface: SwiftUI
   - Language: Swift
   - Storage: Core Data (НЕ выбирайте!)
6. Нажмите Next
7. Выберите папку: `/Users/nikitastarozilov/cursoreTest/ios/CarAssistant`
8. Нажмите Create

## Шаг 2: Удалите созданные файлы

1. Удалите файл `ContentView.swift` (если создан)
2. Удалите файл `CarAssistantApp.swift` (если создан)

## Шаг 3: Добавьте файлы проекта

1. В навигаторе проекта найдите папку `CarAssistant`
2. Правой кнопкой → Add Files to "CarAssistant"
3. Выберите папку `CarAssistant` (внутри `ios/CarAssistant`)
4. Убедитесь, что отмечены:
   - "Copy items if needed" (если нужно)
   - "Create groups"
   - "Add to targets: CarAssistant"
5. Нажмите Add

## Шаг 4: Добавьте Core Data модель

1. File → New → File
2. Выберите "Core Data" → "Data Model"
3. Назовите `CarAssistant`
4. Нажмите Create
5. Удалите созданную модель
6. Добавьте существующую модель:
   - Правой кнопкой на папку `CarAssistant` → Add Files to "CarAssistant"
   - Выберите `CarAssistant.xcdatamodeld`
   - Убедитесь, что отмечен "Add to targets: CarAssistant"
   - Нажмите Add

## Шаг 5: Настройте Info.plist

Добавьте разрешения для микрофона и камеры (уже добавлены в Info.plist)

## Шаг 6: Соберите проект

1. Product → Clean Build Folder (Cmd+Shift+K)
2. Product → Build (Cmd+B)

Готово!
