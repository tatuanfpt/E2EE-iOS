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
