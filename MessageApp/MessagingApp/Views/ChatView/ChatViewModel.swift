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
    var reachedTop: Bool = false
    
    private var firstMessageId: Int?
    var lastMessageId: Int?
    private var cancellable: AnyCancellable?
    private var connectCancellable: AnyCancellable?
    private var fetchMessageCancellable: AnyCancellable?
    
    init(sender: String, receiver: String, service: any SocketService<String, TextMessage>, messageService: MessageService) {
        self.sender = sender
        self.receiver = receiver
        self.service = service
        self.messageService = messageService
            
        fetchMessage()
    }
    
    func subscribe() {
        cancellable = service.subscribeToIncomingMessages()
            .sink { completion in
                switch completion {
                case .finished: print("socket finished")
                case .failure(let error):
                    //TODO: -should implement retry mechanism
                    print("socket get error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                if let id = Int(response.messageId) {
                    self?.messages.append(Message(messageId: id, content: response.message, isFromCurrentUser: false))
                } else {
                    print("❌ cannot get id from message")
                }
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
        messages.append(Message(messageId: 0, content: text, isFromCurrentUser: true))
        service.sendMessage(TextMessage(messageId: "", sender: sender, receiver: receiver, message: text))
    }
    
    func loadFirstMessage() {
        passthroughSubject.send(FetchMessageData(sender: sender, receiver: receiver))
    }
    
    func loadMoreMessages() {
        passthroughSubject.send(FetchMessageData(sender: sender, receiver: receiver, before: firstMessageId, limit: 10))
    }
    
    let passthroughSubject = PassthroughSubject<FetchMessageData, Never>()
    
    private func fetchMessage() {
        fetchMessageCancellable = passthroughSubject
            .delay(for: .seconds(2), scheduler: DispatchQueue.global())
            .flatMap(maxPublishers: .max(1)) { data in
                self.messageService.fetchMessages(data: data)
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished: print("fetch finish")
                case .failure(let error):
                    //TODO: -show error
                    print("❌ fetch get error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] messages in
                guard let self else { return }
                self.messages.insert(contentsOf: messages, at: 0)
                if let firstMessageId = messages.first?.messageId {
                    self.firstMessageId = firstMessageId
                }
                if let lastMessageId = messages.last?.messageId {
                    self.lastMessageId = lastMessageId
                }
                self.reachedTop = false
            }
    }
}
