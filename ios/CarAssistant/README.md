# CarAssistant - iOS приложение

Помощник по автомобилям на SwiftUI с архитектурой MVVM.

## Создание проекта в Xcode

### Важно: Создайте проект через Xcode интерфейс

1. Откройте Xcode
2. File → New → Project
3. Выберите "iOS" → "App"
4. Заполните:
   - Product Name: **CarAssistant**
   - Team: Ваша команда
   - Organization Identifier: **com.carassistant**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - **НЕ выбирайте Core Data!**
5. Выберите папку: `/Users/nikitastarozilov/cursoreTest/ios/CarAssistant`
6. Нажмите Create

### Добавьте файлы проекта

1. В навигаторе проекта удалите созданные файлы (если есть):
   - `ContentView.swift`
   - `CarAssistantApp.swift`

2. Правой кнопкой на папку `CarAssistant` → **Add Files to "CarAssistant"**
3. Выберите папку `CarAssistant` (внутри `ios/CarAssistant`)
4. Убедитесь, что отмечены:
   - ✅ "Create groups"
   - ✅ "Add to targets: CarAssistant"
5. Нажмите **Add**

### Добавьте Core Data модель

1. Правой кнопкой на папку `CarAssistant` → **Add Files to "CarAssistant"**
2. Выберите `CarAssistant.xcdatamodeld`
3. Убедитесь, что отмечен "Add to targets: CarAssistant"
4. Нажмите **Add**

### Настройте модель данных

1. Выберите `CarAssistant.xcdatamodeld` в навигаторе
2. В File Inspector (правая панель):
   - Code Generation: **Manual/None** (уже настроено)
   - Target Membership: ✅ **CarAssistant**

### Соберите проект

1. Product → Clean Build Folder (`Cmd+Shift+K`)
2. Product → Build (`Cmd+B`)

## Структура проекта

- **Views/** - все SwiftUI экраны
- **ViewModels/** - MVVM ViewModels
- **Models/CoreData/** - Core Data классы
- **Utils/** - утилиты (валидация, Core Data, распознавание речи)
- **Resources/** - Assets и конфигурационные файлы

## Готово!

Проект должен собраться без ошибок. Все файлы созданы и настроены правильно.
