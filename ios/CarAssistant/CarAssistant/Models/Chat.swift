import Foundation

struct Chat: Identifiable, Hashable {
    let id: UUID
    let carId: UUID // ID автомобиля, к которому привязан чат
    let title: String
    let lastMessage: String
    let timestamp: Date
    
    init(id: UUID = UUID(), carId: UUID, title: String, lastMessage: String, timestamp: Date = Date()) {
        self.id = id
        self.carId = carId
        self.title = title
        self.lastMessage = lastMessage
        self.timestamp = timestamp
    }
}

