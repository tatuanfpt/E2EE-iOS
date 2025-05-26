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

extension URLRequest {
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    func buildRequest(url: String, parameters: [String: Any]?, method: HttpMethod, headers: [String: String]?, token: String?, body: [String: Any]?) -> URLRequest {
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
