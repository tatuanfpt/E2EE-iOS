//
//  DecryptService.swift
//  MessagingApp
//
//  Created by Sam on 25/5/25.
//

import Foundation

public protocol DecryptService {
    func decryptMessage(with key: Data, combined: Data) throws -> Data
}

import CryptoKit
class AESDecryptService: DecryptService {
    func decryptMessage(with key: Data, combined: Data) throws -> Data {
        do {
            let sealBox = try AES.GCM.SealedBox(combined: combined)
            let result = try AES.GCM.open(sealBox, using: SymmetricKey(data: key))
            return result
        } catch {
            debugPrint("❌ decryptMessage failed key: \(key.asHexString) - data: \(combined.asHexString)")
            throw error
        }
    }

}
