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
    private let user: String
    let service: any SocketService<TextMessage>
    var messages: [Message] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(user: String, service: any SocketService<TextMessage>) {
        self.user = user
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
        service.connect()
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
        LocalSocketService.shared.sendMessage(TextMessage(user: user, message: text))
    }
}
