import Foundation

struct DateFormatterHelper {
    static let shared = DateFormatterHelper()
    
    private let dateFormatter: DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
    }
    
    func formatDate(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        return dateFormatter.string(from: date)
    }
    
    func formatDateShort(_ date: Date) -> String {
        return formatDate(date, dateStyle: .short, timeStyle: .none)
    }
    
    func formatDateTime(_ date: Date) -> String {
        return formatDate(date, dateStyle: .medium, timeStyle: .short)
    }
}

