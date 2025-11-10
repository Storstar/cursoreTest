import Foundation

struct Message: Identifiable, Hashable {
    let id: UUID
    let chatId: UUID
    let content: String
    let isUser: Bool // true - сообщение от пользователя, false - от AI
    let timestamp: Date
    
    init(id: UUID = UUID(), chatId: UUID, content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.chatId = chatId
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}
