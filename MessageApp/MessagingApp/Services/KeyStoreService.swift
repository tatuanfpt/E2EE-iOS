//
//  KeyStoreService.swift
//  MessagingApp
//
//  Created by Sam on 25/5/25.
//

import Foundation

public protocol KeyStoreService {
    func store<T>(key: String, value: T)
    func retrieve<T>(key: String) -> T?
}

final class UserDefaultsKeyStoreService: KeyStoreService {
    private let userDefaults = UserDefaults.standard
    
    func store<T>(key: String, value: T) {
        userDefaults.set(value, forKey: key)
    }
    
    func retrieve<T>(key: String) -> T? {
        return userDefaults.value(forKey: key) as? T
    }
}
