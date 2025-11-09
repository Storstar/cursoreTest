import SwiftUI

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let action: () -> Void
}

struct QuickActionBar: View {
    let actions: [QuickAction]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(actions.enumerated()), id: \.element.id) { index, action in
                    QuickActionButton(
                        action: action,
                        isSelected: selectedIndex == index
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = index
                        }
                        action.action()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct QuickActionButton: View {
    let action: QuickAction
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
                onTap()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(
                                isSelected
                                    ? LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                    )
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                Text(action.title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .frame(width: 90)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

