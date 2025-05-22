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
            viewModel.fetchMessages()
            viewModel.subscribe()
        }
    }
}

@Observable
class ChatViewModel {
    var messages: [Message] = []
    private var cancellables: Set<AnyCancellable> = []
    
    func subscribe() {
        SocketService.shared.subject
            .sink { completion in
                switch completion {
                case .finished: print("socket finished")
                case .failure(let error): print("socket get error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] receivedMessage in
                self?.messages.append(Message(content: receivedMessage, isFromCurrentUser: false))
            }
            .store(in: &cancellables)
    }
    
    func fetchMessages() {
        self.messages = mockMessages
    }
    
    func sendMessage(_ text: String) {
        messages.append(Message(content: text, isFromCurrentUser: true))
        SocketService.shared.sendMessage(text)
    }
}

#Preview {
    ChatView(viewModel: ChatViewModel())
}
