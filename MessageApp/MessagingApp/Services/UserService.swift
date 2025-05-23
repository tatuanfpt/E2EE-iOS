//
//  UserService.swift
//  MessagingApp
//
//  Created by Sam on 22/5/25.
//

import Foundation
import Combine

protocol UserService {
    func fetchUsers() -> AnyPublisher<[User], Error>
}

class RemoteUserService: UserService {
    func fetchUsers() -> AnyPublisher<[User], Error> {
        guard let url = URL(string: "http://localhost:3000/users") else {
            return Fail<[User], Error>(error: NSError(domain: "Invalid URL", code: 0, userInfo: nil)).eraseToAnyPublisher()
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
                
                let list = try JSONDecoder().decode(ListUser.self, from: data)
                return list.users
            }
            .eraseToAnyPublisher()
    }
}
