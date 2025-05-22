//
//  SocketService.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 22/5/25.
//

import Foundation

import Combine
import SocketIO

protocol SocketService<Message> {
    associatedtype Message
    func sendMessage(_ message: Message)
    func subscribeToIncomingMessages() -> AnyPublisher<Message, Error>
}

struct TextMessage: SocketData {
    let user: String
    let message: String
}

class LocalSocketService: SocketService {
    typealias Message = TextMessage
    static let shared = LocalSocketService()
    
    private var manager: SocketManager
    private var socket: SocketIOClient
    
    private let subject = PassthroughSubject<Message, Error>()

    init() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
        socket = manager.defaultSocket

        setupHandlers()
        socket.connect()
    }

    private func setupHandlers() {
        socket.on(clientEvent: .connect) { data, ack in
            print("🔌 Socket connected")
        }

        socket.on("receive-message") { [weak self] data, ack in
            if let user = data[0] as? String,
            let message = data[1] as? String {
                print("📥 Message received: \(message)")
                // You can post a notification or update the UI here
                self?.subject.send(TextMessage(user: user, message: message))
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
        print("📤 Sending: \(message)")
        socket.emit("send-message", message)
    }
    
    func subscribeToIncomingMessages() -> AnyPublisher<Message, Error> {
        subject.eraseToAnyPublisher()
    }
    
    func login(email: String, password: String, completion: @escaping () -> Void) {
        socket.emit("authentication", email, password, completion: completion)
    }
    
}
