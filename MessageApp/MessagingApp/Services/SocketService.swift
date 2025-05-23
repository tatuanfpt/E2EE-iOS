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

struct TextMessage: SocketData {
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
    
    private var manager: SocketManager
    private var socket: SocketIOClient
    
    private let subject = PassthroughSubject<Message, Error>()
    private let connectSubject = PassthroughSubject<Void, Error>()

    init() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
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
            if let dict = data.first as? [String: String],
               let message = dict["text"],
               let user = dict["from"]
            {
                print("📥 Message received: \(message)")
                // You can post a notification or update the UI here
                self?.subject.send(TextMessage(sender: user, receiver: "", message: message))
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

    func sendMessage(_ message: Message) {
        if socket.status != .connected {
            print("❌ Socket not connected yet \(socket.status)")
            return
        }
        print("📤 Sending: \(message)")
        socket.emit("send-message", message)
    }
    
    func subscribeToIncomingMessages() -> AnyPublisher<Message, Error> {
        subject.eraseToAnyPublisher()
    }
    
    func login(email: String, password: String, completion: @escaping () -> Void) {
        socket.emit("register", email, password, completion: completion)
    }
    
}
