import SwiftUI
import CoreData

struct HistoryView: View {
    @EnvironmentObject var requestViewModel: RequestViewModel
    @State private var selectedRequest: Request?
    
    var body: some View {
        List {
            ForEach(requestViewModel.requests, id: \.objectID) { request in
                Button(action: {
                    selectedRequest = request
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(request.type ?? "Неизвестно")
                            .font(.headline)
                        
                        if let text = request.text {
                            Text(text)
                                .font(.subheadline)
                                .lineLimit(2)
                                .foregroundColor(.secondary)
                        }
                        
                        if request.imageData != nil {
                            Text("Фото прикреплено")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Text(formatDate(request.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("История")
        .sheet(isPresented: Binding(
            get: { selectedRequest != nil },
            set: { if !$0 { selectedRequest = nil } }
        )) {
            if let request = selectedRequest, let response = request.response {
                NavigationStack {
                    ResponseView(response: response)
                }
            } else {
                NavigationStack {
                    Text("Ответ не найден")
                        .navigationTitle("Ошибка")
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
