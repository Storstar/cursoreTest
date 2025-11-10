import Foundation

struct Chat: Identifiable, Hashable {
    var id: UUID
    let carId: UUID // ID автомобиля, к которому привязан чат
    var title: String
    var lastMessage: String
    var timestamp: Date
    
    init(id: UUID = UUID(), carId: UUID, title: String, lastMessage: String, timestamp: Date = Date()) {
        self.id = id
        self.carId = carId
        self.title = title
        self.lastMessage = lastMessage
        self.timestamp = timestamp
    }
}

