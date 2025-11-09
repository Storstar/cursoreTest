import Foundation
import CoreData
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var context: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }
    
    // Загрузить чаты для автомобиля
    func loadChats(for carId: UUID) {
        let fetchRequest: NSFetchRequest<ChatCoreData> = ChatCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "carId == %@", carId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ChatCoreData.timestamp, ascending: false)]
        
        do {
            let chatEntities = try context.fetch(fetchRequest)
            chats = chatEntities.map { chatEntity in
                Chat(
                    id: chatEntity.id,
                    carId: chatEntity.carId,
                    title: chatEntity.title ?? "Новый чат",
                    lastMessage: chatEntity.lastMessage ?? "Начните разговор",
                    timestamp: chatEntity.timestamp ?? Date()
                )
            }
        } catch {
            errorMessage = "Ошибка загрузки чатов: \(error.localizedDescription)"
            print("Ошибка загрузки чатов: \(error.localizedDescription)")
        }
    }
    
    // Создать новый чат
    func createChat(carId: UUID) -> Chat {
        let chatEntity = ChatCoreData(context: context)
        let chatId = UUID()
        chatEntity.id = chatId
        chatEntity.carId = carId
        chatEntity.title = "Новый чат"
        chatEntity.lastMessage = "Начните разговор"
        chatEntity.timestamp = Date()
        
        CoreDataManager.shared.save()
        
        let newChat = Chat(
            id: chatId,
            carId: carId,
            title: "Новый чат",
            lastMessage: "Начните разговор",
            timestamp: Date()
        )
        chats.insert(newChat, at: 0)
        return newChat
    }
    
    // Обновить чат
    func updateChat(_ chat: Chat) {
        let fetchRequest: NSFetchRequest<ChatCoreData> = ChatCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", chat.id as CVarArg)
        
        do {
            if let chatEntity = try context.fetch(fetchRequest).first {
                chatEntity.title = chat.title
                chatEntity.lastMessage = chat.lastMessage
                chatEntity.timestamp = chat.timestamp
                CoreDataManager.shared.save()
                
                // Обновляем в массиве
                if let index = chats.firstIndex(where: { $0.id == chat.id }) {
                    chats[index] = chat
                }
            }
        } catch {
            errorMessage = "Ошибка обновления чата: \(error.localizedDescription)"
            print("Ошибка обновления чата: \(error.localizedDescription)")
        }
    }
    
    // Удалить чат
    func deleteChat(_ chat: Chat) {
        let fetchRequest: NSFetchRequest<ChatCoreData> = ChatCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", chat.id as CVarArg)
        
        do {
            if let chatEntity = try context.fetch(fetchRequest).first {
                context.delete(chatEntity)
                CoreDataManager.shared.save()
                
                // Удаляем из массива
                chats.removeAll { $0.id == chat.id }
            }
        } catch {
            errorMessage = "Ошибка удаления чата: \(error.localizedDescription)"
            print("Ошибка удаления чата: \(error.localizedDescription)")
        }
    }
    
    // Загрузить сообщения для чата
    func loadMessages(for chatId: UUID) -> [Message] {
        let fetchRequest: NSFetchRequest<ChatMessageCoreData> = ChatMessageCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", chatId as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ChatMessageCoreData.timestamp, ascending: true)]
        
        do {
            let messageEntities = try context.fetch(fetchRequest)
            return messageEntities.map { messageEntity in
                Message(
                    id: messageEntity.id,
                    chatId: messageEntity.chatId,
                    content: messageEntity.content ?? "",
                    isUser: messageEntity.isUser,
                    timestamp: messageEntity.timestamp ?? Date()
                )
            }
        } catch {
            errorMessage = "Ошибка загрузки сообщений: \(error.localizedDescription)"
            print("Ошибка загрузки сообщений: \(error.localizedDescription)")
            return []
        }
    }
    
    // Сохранить сообщение
    func saveMessage(_ message: Message) {
        let messageEntity = ChatMessageCoreData(context: context)
        messageEntity.id = message.id
        messageEntity.chatId = message.chatId
        messageEntity.content = message.content
        messageEntity.isUser = message.isUser
        messageEntity.timestamp = message.timestamp
        
        // Связываем с чатом
        let chatFetchRequest: NSFetchRequest<ChatCoreData> = ChatCoreData.fetchRequest()
        chatFetchRequest.predicate = NSPredicate(format: "id == %@", message.chatId as CVarArg)
        
        do {
            if let chatEntity = try context.fetch(chatFetchRequest).first {
                messageEntity.chat = chatEntity
            }
        } catch {
            print("Ошибка связывания сообщения с чатом: \(error.localizedDescription)")
        }
        
        CoreDataManager.shared.save()
    }
}

