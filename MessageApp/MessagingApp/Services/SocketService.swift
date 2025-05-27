//
//  SocketService.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 22/5/25.
//

import Foundation

import Combine
import SocketIO

protocol SocketService<User, Message> {
    associatedtype User
    associatedtype Message
    func connect(user: User) -> AnyPublisher<Void, Error>
    //TODO: -display status of message: sending, sent, read
    func sendMessage(_ message: Message)
    func subscribeToIncomingMessages() -> AnyPublisher<Message, Error>
}

// TODO: should extract to send and receive model
struct TextMessage: SocketData {
    let messageId: String
    let sender: String
    let receiver: String
    let message: String
    
    func socketRepresentation() -> SocketData {
        return ["sender": sender, "receiver": receiver, "text": message]
    }
}

class LocalSocketService: SocketService {
    typealias Message = TextMessage
    typealias User = String
    
    private let manager: SocketManager
    private let socket: SocketIOClient
    private let encryptService: EncryptService
    private let decryptService: DecryptService
    private let keyStore: KeyStoreService
    
    private let subject = PassthroughSubject<Message, Error>()
    private let connectSubject = PassthroughSubject<Void, Error>()

    init(encryptService: EncryptService, decryptService: DecryptService, keyStore: KeyStoreService) {
        self.encryptService = encryptService
        self.decryptService = decryptService
        self.keyStore = keyStore
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(false), .compress])
        socket = manager.defaultSocket
        
        setupHandlers()
    }
    
    func connect(user: User) -> AnyPublisher<Void, Error> {
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("🔌 Socket connected \(self?.socket.status)")
            self?.registerUser(user)
        }
        
        socket.connect()
        return connectSubject.eraseToAnyPublisher()
    }
    
    private func registerUser(_ user: User) {
        socket.on("register") { [weak self] _, _ in
            print("🔌 Socket registered successfully with user: \(user) - \(self?.socket.status)")
            self?.connectSubject.send(())
        }
        socket.emit("register", user)
    }

    private func setupHandlers() {

        socket.on("receive-message") { [weak self] data, ack in
            if let dict = data.first as? [String: Any],
               let message = dict["text"] as? String,
               let user = dict["from"] as? String,
               let id = dict["messageId"] as? Int
            {
                guard let self else { return }
                print("📥 Message received: \(message)")
                // You can post a notification or update the UI here
                let decryptedMessage = decryptMessage(message: message)
                subject.send(TextMessage(messageId: String("\(id)"), sender: user, receiver: "", message: decryptedMessage))
                
            } else {
                print("❌ invalid data \(data)")
            }
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("❌ Socket disconnected")
        }
        
        socket.on(clientEvent: .error) { error, ack in
            print("❌ Socket error \(error)")
        }
    }
    
    private func decryptMessage(message: String) -> String {
        do {
            guard let messageData = Data(base64Encoded: message),
                  let key = keyStore.retrieve(key: .secureKey) as? Data else {
                print("❌ cannot convert message to data")
                return ""
            }

            let decryptedMessage = try decryptService.decryptMessage(with: key, combined: messageData)
            guard let result = String(data: decryptedMessage, encoding: .utf8) else {
                print("❌ cannot convert data to message")
                return ""
            }
            return result
            
        } catch {
            print("❌ cannot decrypt message")
        }
        return ""
    }

    func sendMessage(_ message: Message) {
        if socket.status != .connected {
            print("❌ Socket not connected yet \(socket.status)")
            return
        }
        print("📤 Sending: \(message)")
        let encryptMessage = encryptMessage(message: message.message)
        let encryptedMessage: Message = Message(messageId: message.messageId, sender: message.sender, receiver: message.receiver, message: encryptMessage)
        socket.emit("send-message", encryptedMessage)
    }
    
    private func encryptMessage(message: String) -> String {
        guard let messageData = message.data(using: .utf8) else {
            print("❌ cannot convert message to data")
            return ""
        }
        
        guard let key = keyStore.retrieve(key: .secureKey) as? Data,
              let encryptedMessageData = try? encryptService.encryptMessage(with: key, plainText: messageData) else {
            print("❌ cannot encrypt message")
            return ""
        }
        
        let encryptedMessageString = encryptedMessageData.base64EncodedString()
        return encryptedMessageString
    }
    
    func subscribeToIncomingMessages() -> AnyPublisher<Message, Error> {
        subject.eraseToAnyPublisher()
    }
    
    func login(email: String, password: String, completion: @escaping () -> Void) {
        socket.emit("register", email, password, completion: completion)
    }
    
}
