//
//  ChatViewModel.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 22/5/25.
//

import Foundation
import Observation
import Combine

@Observable
class ChatViewModel {
    //TODO: -should be let
    var sender: String
    var receiver: String
    let service: any SocketService<String, TextMessage>
    let messageService: MessageService
    var messages: [Message] = []
    private var cancellable: AnyCancellable?
    private var connectCancellable: AnyCancellable?
    private var fetchMessageCancellable: AnyCancellable?
    
    init(sender: String, receiver: String, service: any SocketService<String, TextMessage>, messageService: MessageService) {
        self.sender = sender
        self.receiver = receiver
        self.service = service
        self.messageService = messageService
    }
    
    func subscribe() {
        print("🙈 sender: \(sender) to receiver: \(receiver)")
        cancellable = service.subscribeToIncomingMessages()
            .sink { completion in
                switch completion {
                case .finished: print("socket finished")
                case .failure(let error): print("socket get error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                self?.messages.append(Message(content: response.message, isFromCurrentUser: false))
            }
        
        connect()
    }
    
    private func connect() {
        connectCancellable = service.connect(user: sender)
            .sink { completion in
                switch completion {
                    case .finished: print("socket connected")
                case .failure(let error):
                    //TODO: -show no connection state
                    print("socket get error: \(error.localizedDescription)")
                }
            } receiveValue: { _ in
                //TODO: -show connected state
                print("socket connected")
            }
    }
    
    func sendMessage(_ text: String) {
        messages.append(Message(content: text, isFromCurrentUser: true))
        service.sendMessage(TextMessage(sender: sender, receiver: receiver, message: text))
    }
    
    func fetchMessages() {
        fetchMessageCancellable = messageService.fetchMessages(data: FetchMessageData(sender: sender, receiver: receiver))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished: print("fetch finish")
                case .failure(let error): print("❌ fetch get error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
    }
}
