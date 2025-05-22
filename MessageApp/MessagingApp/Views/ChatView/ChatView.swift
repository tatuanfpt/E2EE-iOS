//
//  ChatView.swift
//  MessagingApp
//
//  Created by Sam on 21/5/25.
//

import SwiftUI

import Combine

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    @FocusState private var isFocused: Bool
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            MessageListView(messages: $viewModel.messages, isFocused: $isFocused)
                .onTapGesture {
                    isFocused = false
                }
            MessageTextField() { text in
                viewModel.sendMessage(text)
            }
            .focused($isFocused)
            .padding()
        }
        .clipped()
        .onAppear {
            viewModel.subscribe()
        }
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel(sender: "slh", receiver: "", service: NullSocketService<String, TextMessage>()))
}
