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

class LocalSocketService: SocketService {
    static let shared = LocalSocketService()
    
    private var manager: SocketManager
    private var socket: SocketIOClient
    
    private let subject = PassthroughSubject<String, Error>()

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

        socket.on("message") { [weak self] data, ack in
            if let message = data[0] as? String {
                print("📥 Message received: \(message)")
                // You can post a notification or update the UI here
                self?.subject.send(message)
            }
        }

        socket.on(clientEvent: .disconnect) { data, ack in
            print("❌ Socket disconnected")
        }
    }

    func sendMessage(_ message: String) {
        print("📤 Sending: \(message)")
        socket.emit("message", message)
    }
    
    func subscribeToIncomingMessages() -> AnyPublisher<String, Error> {
        subject.eraseToAnyPublisher()
    }
    
}
