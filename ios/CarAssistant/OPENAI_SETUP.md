# Настройка OpenRouter API

## Шаг 1: Получение API ключа

1. Зарегистрируйтесь на [OpenRouter](https://openrouter.ai/)
2. Пополните баланс (минимум $1)
3. Перейдите в раздел [API Keys](https://openrouter.ai/keys)
4. Создайте новый API ключ
5. Скопируйте ключ (формат: `sk-or-v1-...`)

## Шаг 2: Установка API ключа в приложение

Откройте файл `CarAssistant/Info.plist` и найдите ключи:

```xml
<key>OpenRouterAPIKey</key>
<string>YOUR_OPENROUTER_API_KEY_HERE</string>
<key>OpenRouterReferer</key>
<string>https://carassistant.app/</string>
<key>OpenRouterAppTitle</key>
<string>Car Assistant</string>
```

Замените `YOUR_OPENROUTER_API_KEY_HERE` на ваш реальный API ключ:

```xml
<key>OpenRouterAPIKey</key>
<string>sk-or-v1-your-actual-api-key-here</string>
<key>OpenRouterReferer</key>
<string>https://carassistant.app/</string>
<key>OpenRouterAppTitle</key>
<string>Car Assistant</string>
```

**Важно:** 
- API ключ хранится в `Info.plist`, что является стандартным способом хранения конфигурации в iOS приложениях
- `OpenRouterReferer` - адрес вашего приложения (можно изменить на свой домен)
- `OpenRouterAppTitle` - название приложения (можно изменить)

## Пример использования

Функция `sendMessageWithCarContext` автоматически вызывается при отправке текстового сообщения в чате. Она:

1. Формирует system prompt с контекстом автомобиля (модель, год, история обслуживания)
2. Отправляет запрос к OpenRouter API (GPT-5 через OpenRouter)
3. Возвращает ответ от AI

### Пример вызова из кода:

```swift
let response = try await AIService.shared.sendMessageWithCarContext(
    message: "Когда нужно менять масло?",
    model: "Audi A6",
    year: "2022",
    serviceHistory: "март 2024 — менялось масло, фильтр, тормозные колодки"
)
```

### Автоматическое использование в чате:

При отправке сообщения в чате приложение автоматически:
- Берет данные текущего выбранного автомобиля
- Загружает всю историю ТО
- Формирует контекст и отправляет запрос к OpenRouter API

## Безопасность

⚠️ **ВАЖНО**: В продакшене не храните API ключ в коде!

Рекомендуемые варианты:
1. Используйте Keychain для хранения ключа
2. Используйте переменные окружения
3. Используйте серверный прокси для запросов

## Модель

По умолчанию используется модель `openai/gpt-5` через OpenRouter. Если эта модель недоступна, измените в `AIService.swift`:

```swift
private let model = "openai/gpt-4" // или другая доступная модель через OpenRouter
```

Доступные модели на OpenRouter можно посмотреть на [https://openrouter.ai/models](https://openrouter.ai/models)

