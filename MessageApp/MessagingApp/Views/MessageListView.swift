//
//  MessageListView.swift
//  MessagingApp
//
//  Created by Sam on 20/5/25.
//

import SwiftUI

struct Message: Identifiable, Hashable {
    let id = UUID()
    let content: String
    let isFromCurrentUser: Bool
}

struct MessageListView: View {
    @Binding var messages: [Message]
    @FocusState<Bool>.Binding var isFocused: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            List(messages) { message in
                HStack {
                    if message.isFromCurrentUser {
                        Spacer()
                    }
                    MessageView(content: message.content)
                }
                .listRowSeparator(.hidden)
                .id(message.id)
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .onChange(of: messages, { _, _ in
                scrollToBottom(proxy)
            })
            .onChange(of: isFocused, { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    scrollToBottom(proxy)
                }
            })
            .scrollContentBackground(.hidden)
        }
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo(messages.last?.id)
        }
    }
}

#Preview {
    @Previewable @FocusState var isFocused: Bool
    MessageListView(messages: Binding.constant(mockMessages), isFocused: $isFocused)
}
