//
//  EncryptService.swift
//  MessagingApp
//
//  Created by Sam on 25/5/25.
//

import Foundation

public protocol EncryptService {
    func encryptMessage(with key: Data, plainText: Data) throws -> Data?
}

import CryptoKit
class AESEncryptService: EncryptService {
    public func encryptMessage(with key: Data, plainText: Data) throws -> Data? {
        do {
            let sealedData = try AES.GCM.seal(
                plainText,
                using: SymmetricKey(data: key)
            )
            return sealedData.combined
        } catch {
            debugPrint("❌ encryptMessage failed \(error.localizedDescription)")
            throw error
        }
    }
}
