//
//  PromptBuilderExamples.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//  Примеры использования PromptBuilder
//

import Foundation

// MARK: - Примеры использования PromptBuilder

/*
 
 // ПРИМЕР 1: Нажата кнопка Check Engine, пользователь ввёл текст
 
 let builder = PromptBuilder()
 
 // Подготовка данных
 guard let vehicle = PromptBuilder.vehicle(from: car),
       let user = authViewModel.currentUser else {
     return
 }
 
 let geo = PromptBuilder.geo(from: user)
 
 // Загружаем историю обслуживания
 let fetchRequest: NSFetchRequest<MaintenanceRecord> = MaintenanceRecord.fetchRequest()
 fetchRequest.predicate = NSPredicate(format: "car == %@", car)
 let records = try context.fetch(fetchRequest)
 let maintenanceRecords = PromptBuilder.maintenanceRecords(from: records)
 
 // Получаем тему из активной кнопки
 let selectedTopic = PromptBuilder.topic(from: "Check Engine") ?? .general_question
 
 // Строим system prompt
 let systemPrompt = builder.buildSystemPrompt(
     vehicle: vehicle,
     records: maintenanceRecords,
     geo: geo,
     topic: selectedTopic,
     hasImages: false
 )
 
 // Строим messages
 let chatHistory: [[String: String]] = [] // История чата
 let messages = builder.buildMessages(
     systemPrompt: systemPrompt,
     chatHistory: chatHistory,
     userContent: .text("Загорелся чек, мотор троит на холодную. Что смотреть сначала?")
 )
 
 // Отправляем запрос через AIService
 Task {
     do {
         let response = try await AIService.shared.sendRequestWithMessages(
             messages: messages,
             model: "openai/gpt-4o"
         )
         print("Ответ: \(response)")
     } catch {
         print("Ошибка: \(error)")
     }
 }
 
 // ПРИМЕР 2: Нажата кнопка Brakes, пользователь отправил фото
 
 let base64Image = imageData.base64EncodedString()
 
 let systemPrompt2 = builder.buildSystemPrompt(
     vehicle: vehicle,
     records: maintenanceRecords,
     geo: geo,
     topic: .brakes,
     hasImages: true
 )
 
 let messages2 = builder.buildMessages(
     systemPrompt: systemPrompt2,
     chatHistory: chatHistory,
     userContent: .images(
         imagesBase64: [base64Image],
         text: "При торможении сильная вибрация. Посмотри диски/колодки на фото и скажи, что делать."
     )
 )
 
 Task {
     do {
         let response2 = try await AIService.shared.sendRequestWithMessages(
             messages: messages2,
             model: "openai/gpt-4o"
         )
         print("Ответ: \(response2)")
     } catch {
         print("Ошибка: \(error)")
     }
 }
 
 */

