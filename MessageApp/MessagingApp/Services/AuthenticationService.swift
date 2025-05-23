//
//  AuthenticationService.swift
//  MessagingApp
//
//  Created by SinhLH.AVI on 22/5/25.
//

import Foundation

import Combine
protocol AuthenticationService<Authentication> {
    associatedtype Authentication
    func login(data: Authentication) -> AnyPublisher<Bool, Error>
}

struct PasswordAuthentication {
    let email: String
    let password: String
}

struct User: Identifiable, Hashable, Codable {
    let id: Int
    let username: String
}

struct ListUser: Codable {
    let users: [User]
}

final class PasswordAuthenticationService: AuthenticationService {
    
    func login(data: PasswordAuthentication) -> AnyPublisher<Bool, Error> {
        let subject = PassthroughSubject<Bool, Error>()
        guard let url = URL(string: "http://localhost:3000/users") else {
            return Fail<Bool, Error>(error: NSError(domain: "Invalid URL", code: 0, userInfo: nil)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["username": data.email]
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                let user = try? JSONDecoder().decode(User.self, from: data)
                subject.send(true)
            } else {
                subject.send(false)
            }
        }.resume()
        
        return subject.eraseToAnyPublisher()
    }
}
