//
//  MessageListView.swift
//  MessagingApp
//
//  Created by Sam on 20/5/25.
//

import SwiftUI

struct Message: Identifiable, Hashable {
    let id = UUID()
    let messageId: Int
    let content: String
    let isFromCurrentUser: Bool
}

struct MessageListView: View {
    @Binding var reachedTop: Bool
    @Binding var messages: [Message]
    @FocusState<Bool>.Binding var isFocused: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(messages) { message in
                    LazyVStack(alignment: .leading) {
                        HStack {
                            if message.isFromCurrentUser {
                                Spacer()
                            }
                            MessageView(content: message.content)
                        }
                        .id(message.id)
                        if reachedTop {
                            ProgressView()
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: messages, { _, _ in
                //TODO: If the user is scrolling up, do not scroll to the bottom.
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
    MessageListView(reachedTop: Binding.constant(false), messages: Binding.constant(mockMessages), isFocused: $isFocused)
}
