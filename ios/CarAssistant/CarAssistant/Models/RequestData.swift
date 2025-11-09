import Foundation

enum RequestType: String, Codable {
    case text
    case voice
    case photo
}

struct RequestData: Identifiable {
    let id: UUID
    var text: String?
    var imageData: Data?
    var type: RequestType
    var createdAt: Date
    
    init(id: UUID = UUID(), text: String? = nil, imageData: Data? = nil, type: RequestType, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.imageData = imageData
        self.type = type
        self.createdAt = createdAt
    }
}


