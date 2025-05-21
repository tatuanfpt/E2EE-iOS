//
//  ChatView.swift
//  MessagingApp
//
//  Created by Sam on 21/5/25.
//

import SwiftUI

struct ChatView: View {
    @State private var messages: [Message] = []
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            MessageListView(messages: $messages, isFocused: $isFocused)
                .onTapGesture {
                    isFocused = false
                }
            MessageTextField() { text in
                messages.append(Message(content: text, isFromCurrentUser: true))
            }
            .focused($isFocused)
            .padding()
        }
        .clipped()
        .onAppear {
            self.messages = mockMessages
        }
    }
}

#Preview {
    ChatView()
}
