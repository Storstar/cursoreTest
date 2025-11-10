//
//  ToastView.swift
//  CarAssistant
//
//  Created on 10.11.2024.
//

import SwiftUI

// MARK: - ToastView

/// Компонент для отображения тостов
struct ToastView: View {
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        if isPresented {
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.8))
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
        }
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var toastMessage: String?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let message = toastMessage {
                VStack {
                    Spacer()
                    ToastView(message: message, isPresented: Binding(
                        get: { toastMessage != nil },
                        set: { if !$0 { toastMessage = nil } }
                    ))
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

extension View {
    func toast(message: Binding<String?>) -> some View {
        modifier(ToastModifier(toastMessage: message))
    }
}

