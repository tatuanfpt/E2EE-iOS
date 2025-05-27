//
//  MessageService.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 26/5/25.
//

import Foundation
import Combine
import CryptoKit

struct FetchMessageData {
    let sender: String
    let receiver: String
    let before: Int?
    let limit: Int?
    let firstLoad: Bool
    
    init(sender: String, receiver: String, before: Int? = nil, limit: Int? = nil, firstLoad: Bool) {
        self.sender = sender
        self.receiver = receiver
        self.before = before
        self.limit = limit
        self.firstLoad = firstLoad
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

struct SaltResponse: Codable {
//    let senderId: Int
//    let receiverId: Int
    let salt: String
}

struct PublicKeyResponse: Codable {
    let publicKey: String
}

class RemoteMessageService: MessageService {
    private let secureKey: any SecureKeyService<P256ExchangeKey, P256KeyData>
    private let keyStore: KeyStoreService
    private let decryptService: DecryptService
    
    init(secureKey: any SecureKeyService<P256ExchangeKey, P256KeyData>, keyStore: KeyStoreService, decryptService: DecryptService) {
        self.secureKey = secureKey
        self.keyStore = keyStore
        self.decryptService = decryptService
    }
    
    private func fetchSalt(sender: String, receiver: String) -> AnyPublisher<String, Error> {
        let urlString = "http://localhost:3000/session"
        
        let urlRequest = buildRequest(url: urlString, method: .post, body: [
            "senderUsername": sender,
            "receiverUsername": receiver
        ])
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                
                guard let code = (response as? HTTPURLResponse)?.statusCode else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                guard code == 200 else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                let salt = try JSONDecoder().decode(SaltResponse.self, from: data)
                return salt.salt
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchReceiverKey(username: String) -> AnyPublisher<String, Error> {
        let urlString = "http://localhost:3000/keys/\(username)"
        
        let urlRequest = buildRequest(url: urlString)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                
                guard let code = (response as? HTTPURLResponse)?.statusCode else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                guard code == 200 else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                let result = try JSONDecoder().decode(PublicKeyResponse.self, from: data)
                return result.publicKey
            }
            .eraseToAnyPublisher()
    }
    
    private func generateSecreteKey(salt: Data, publicKey: Data, privateKey: Data) throws -> Data {
        let sharedInfo = "Message".data(using: .utf8)!
        print("🔑 publickey ", publicKey.asHexString)
        print("🔑 salt ", salt.asHexString)
        print("🔑 privateKey ", privateKey.asHexString)
        return try secureKey.generateSecureKey(data: P256KeyData(privateKey: privateKey, publicKey: publicKey, salt: salt, hashFunction: SHA256.self, sharedInfo: sharedInfo, outputByteCount: 32))
    }
    
    func fetchMessages(data: FetchMessageData) -> AnyPublisher<[Message], any Error> {
        fetchReceiverKey(username: data.receiver)
            .flatMap { publicKey -> AnyPublisher<(String, String), Error> in
                self.fetchSalt(sender: data.sender, receiver: data.receiver)
                    .map { salt in (publicKey, salt) }
                    .eraseToAnyPublisher()
            }
            .tryMap { publicKey, salt -> (Data, Data, Data) in
                guard let publicKeyData = Data(base64Encoded: publicKey),
                      let saltData = Data(base64Encoded: salt),
                      let privateKey = self.keyStore.retrieve(key: data.sender) else {
                    throw NSError(domain: "Invalid base64 string", code: 0, userInfo: nil)
                }
                return (publicKeyData, saltData, privateKey)
            }
            .tryMap { publicKey, salt, privateKey -> Data in
                return try self.generateSecreteKey(salt: salt, publicKey: publicKey, privateKey: privateKey)
            }
            .flatMap { secureKey in
//                print("🔑 \(secureKey.asHexString)")
                self.keyStore.store(key: .secureKey, value: secureKey)
                return self.fetchEncryptedMessages(data: data)
                    .map { messages in
                        self.decryptMessage(messages, secureKey: secureKey)
                    }
            }
            .eraseToAnyPublisher()
            
    }
    
    private func decryptMessage(_ messages: [Message], secureKey: Data) -> [Message] {
        messages.map { message in
            let content = try? self.decryptService.decryptMessage(with: secureKey, combined: Data(base64Encoded: message.content) ?? Data())
            let text = String(data: content ?? Data(), encoding: .utf8) ?? ""
            return Message(messageId: message.messageId, content: text, isFromCurrentUser: message.isFromCurrentUser)}
    }
    
    private func fetchEncryptedMessages(data: FetchMessageData) -> AnyPublisher<[Message], any Error> {
        let sender = data.sender
        let urlString = "http://localhost:3000/messages/\(data.sender)/\(data.receiver)"
        
        var params = [String: Any]()
        if let before = data.before {
            params["before"] = before
        }
        if let limit = data.limit {
            params["limit"] = limit
        }
        
        let urlRequest = buildRequest(url: urlString, parameters: params)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
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
