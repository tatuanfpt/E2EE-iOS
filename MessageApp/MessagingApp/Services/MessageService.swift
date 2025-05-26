//
//  MessageService.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 26/5/25.
//

import Foundation
import Combine

struct FetchMessageData {
    let sender: String
    let receiver: String
    let before: Int?
    let limit: Int?
    
    init(sender: String, receiver: String, before: Int? = nil, limit: Int? = nil) {
        self.sender = sender
        self.receiver = receiver
        self.before = before
        self.limit = limit
    }
}

protocol MessageService {
    func fetchMessages(data: FetchMessageData) -> AnyPublisher<[Message], Error>
}

struct MessageResponse: Codable {
    let id: Int
    let sender: String
    let receiverId: Int
    let text: String
    let createdAt: String
}

class RemoteMessageService: MessageService {
    func fetchMessages(data: FetchMessageData) -> AnyPublisher<[Message], any Error> {
        let sender = data.sender
        guard let url = URL(string: "http://localhost:3000/messages/\(data.sender)/\(data.receiver)") else {
            return Fail<[Message], Error>(error: NSError(domain: "Invalid URL", code: 0, userInfo: nil)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                
                guard let code = (response as? HTTPURLResponse)?.statusCode else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                guard code == 200 else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                let list = try JSONDecoder().decode([MessageResponse].self, from: data)
                return list.map { Message(messageId: $0.id, content: $0.text, isFromCurrentUser: $0.sender == sender)}
            }
            .eraseToAnyPublisher()
    }
}
