//
//  ChatViewModel.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 22/5/25.
//

import Observation
import Combine

@Observable
class ChatViewModel {
    let service: any SocketService<String>
    var messages: [Message] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(service: any SocketService<String>) {
        self.service = service
    }
    
    func subscribe() {
        service.subscribeToIncomingMessages()
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
        LocalSocketService.shared.sendMessage(text)
    }
}
