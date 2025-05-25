//
//  SecureKeyService.swift
//  MessagingApp
//
//  Created by Sam on 25/5/25.
//

import Foundation
public protocol SecureKeyService {
    func generatePublicKey() -> Data
    func generateKey(encryptKey: Data, decryptKey: Data) throws -> Data
}

import CryptoKit
public final class P256SecureKeyService: SecureKeyService {
    typealias PublicKey = P256.KeyAgreement.PublicKey
    typealias PrivateKey = P256.KeyAgreement.PrivateKey
    
    private let privateKey = P256.KeyAgreement.PrivateKey()
    
    private let salt: any DataProtocol
    private let hashFunction: any HashFunction.Type
    private let sharedInfo: any DataProtocol
    private let outputByteCount: Int
    
    init(hashFunction: any HashFunction.Type, salt: any DataProtocol, sharedInfo: any DataProtocol, outputByteCount: Int) {
        self.hashFunction = hashFunction
        self.salt = salt
        self.sharedInfo = sharedInfo
        self.outputByteCount = outputByteCount
    }
    
    public func generatePublicKey() -> Data {
        return privateKey.publicKey.rawRepresentation
    }
    
    public func generateKey(encryptKey: Data, decryptKey: Data) throws -> Data {
        let privateKey = try PrivateKey(rawRepresentation: encryptKey)
        let publicKey = try PublicKey(rawRepresentation: decryptKey)
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        let key = sharedSecret.hkdfDerivedSymmetricKey(using: hashFunction, salt: salt, sharedInfo: sharedInfo, outputByteCount: outputByteCount)
        return key.withUnsafeBytes { Data($0) }
    }
}
