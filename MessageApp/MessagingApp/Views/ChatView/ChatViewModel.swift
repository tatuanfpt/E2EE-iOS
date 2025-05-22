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
    private let sender: String
    private let receiver: String
    let service: any SocketService<String, TextMessage>
    var messages: [Message] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(sender: String, receiver: String, service: any SocketService<String, TextMessage>) {
        self.sender = sender
        self.receiver = receiver
        self.service = service
    }
    
    func subscribe() {
        service.subscribeToIncomingMessages()
            .sink { completion in
                switch completion {
                case .finished: print("socket finished")
                case .failure(let error): print("socket get error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                self?.messages.append(Message(content: response.message, isFromCurrentUser: false))
            }
            .store(in: &cancellables)
        
        connect()
    }
    
    private func connect() {
        service.connect(user: sender)
            .sink { completion in
                switch completion {
                    case .finished: print("socket connected")
                case .failure(let error):
                    //TODO: -show no connection state
                    print("socket get error: \(error.localizedDescription)")
                }
            } receiveValue: { _ in
                //TODO: -show connected state
            }
            .store(in: &cancellables)
    }
    
    func sendMessage(_ text: String) {
        messages.append(Message(content: text, isFromCurrentUser: true))
        LocalSocketService.shared.sendMessage(TextMessage(sender: sender, receiver: receiver, message: text))
    }
}
