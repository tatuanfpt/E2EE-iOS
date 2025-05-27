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

extension String {
    static let secureKey = "SECURE_KEY"
    static let isLogIn = "IS_LOG_IN"
}

final class PasswordAuthenticationService: AuthenticationService {
    
    private let secureKeyService: any SecureKeyService<P256ExchangeKey, P256KeyData>
    private let keyStore: KeyStoreService
    
    init(secureKeyService: any SecureKeyService<P256ExchangeKey, P256KeyData>, keyStore: KeyStoreService) {
        self.secureKeyService = secureKeyService
        self.keyStore = keyStore
    }
    
    func login(data: PasswordAuthentication) -> AnyPublisher<Bool, Error> {
        return registerUser(username: data.email)
            .flatMap { _ in
                let exchangeKey = self.secureKeyService.generateExchangeKey()
                self.keyStore.store(key: data.email, value: exchangeKey.privateKey)
                return self.sendPublicKey(user: data.email, publicKey:  exchangeKey.publicKey)
            }
            .map { _ in
                return true
            }
            .first()
            .eraseToAnyPublisher()
    }
    
    private func sendPublicKey(user: String, publicKey: Data) -> AnyPublisher<Void, Error> {
        let urlString = "http://localhost:3000/keys"
        
        let request = buildRequest(url: urlString, method: .post, body: [
            "username": user,
            "publicKey": publicKey.base64EncodedString()
        ])
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                
                guard let code = (response as? HTTPURLResponse)?.statusCode else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                guard code == 200 else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                return Void()
            }
            .eraseToAnyPublisher()
    }
    
    private func registerUser(username: String) -> AnyPublisher<Void, Error> {
        let urlString = "http://localhost:3000/users"
        
        let request = buildRequest(url: urlString, method: .post, body: ["username": username])
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                
                guard let code = (response as? HTTPURLResponse)?.statusCode else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                guard code == 200 else {
                    let error = URLError(.badServerResponse)
                    throw error
                }
                
                return Void()
            }
            .eraseToAnyPublisher()
    }
}

extension URLRequest {
    public mutating func addApplicationJsonContentAndAcceptHeaders() {
        let value = "application/json"
        addValue(value, forHTTPHeaderField: "Content-Type")
        addValue(value, forHTTPHeaderField: "Accept")
    }
    
    public mutating func setBearerToken(_ token: String) {
        setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}

extension URLComponents {
    mutating func addQueryParameters(params: [String: Any]) {
        queryItems = [URLQueryItem]()
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            queryItems?.append(queryItem)
        }
    }
}

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

func buildRequest(url: String, parameters: [String: Any]? = nil, method: HttpMethod = .get, headers: [String: String]? = nil, token: String? = nil, body: [String: Any]? = nil) -> URLRequest {
    var components = URLComponents(string: url)

    // URLComponents(string: url) can't init with url params contains double quote
    if components == nil, let urlQueryAllowed = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        components = URLComponents(string: urlQueryAllowed)
    }
    
    if let parameters = parameters {
        components?.addQueryParameters(params: parameters)
    }

    guard let urlWithParameters = components?.url else {
        return URLRequest(url: URL(fileURLWithPath: ""))
    }

    var urlRequest = URLRequest(url: urlWithParameters)
    urlRequest.httpMethod = method.rawValue
    urlRequest.addApplicationJsonContentAndAcceptHeaders()

    for (headerField, value) in headers ?? [:] {
        urlRequest.addValue(value, forHTTPHeaderField: headerField)
    }

    if let token = token {
        urlRequest.setBearerToken(token)
    }

    if let body = body, let data = try? JSONSerialization.data(withJSONObject: body) {
        urlRequest.httpBody = data
    }

    return urlRequest
}
