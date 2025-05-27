//
//  KeyStoreService.swift
//  MessagingApp
//
//  Created by Sam on 25/5/25.
//

import Foundation

public protocol KeyStoreService {
    func store(key: String, value: Data)
    func retrieve(key: String) -> Data?
}

final class UserDefaultsKeyStoreService: KeyStoreService {
    private let userDefaults = UserDefaults.standard
    
    func store(key: String, value: Data) {
        userDefaults.set(value, forKey: key)
    }
    
    func retrieve(key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }
}
