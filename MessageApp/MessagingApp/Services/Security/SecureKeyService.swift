//
//  SecureKeyService.swift
//  MessagingApp
//
//  Created by Sam on 25/5/25.
//

import Foundation
public protocol SecureKeyService<ExchangeKey, SecureKey> {
    associatedtype ExchangeKey
    associatedtype SecureKey
    func generateExchangeKey() -> ExchangeKey
    func generateSecureKey(data: SecureKey) throws -> Data
}

import CryptoKit

public struct P256ExchangeKey {
    let publicKey: Data
    let privateKey: Data
}

public struct P256KeyData {
    let privateKey: Data
    let publicKey: Data
    let salt: any DataProtocol
    let hashFunction: any HashFunction.Type
    let sharedInfo: any DataProtocol
    let outputByteCount: Int
}

public final class P256SecureKeyService: SecureKeyService {
    typealias PublicKey = P256.KeyAgreement.PublicKey
    typealias PrivateKey = P256.KeyAgreement.PrivateKey
    public typealias SecureKey = P256KeyData
    public typealias ExchangeKey = P256ExchangeKey
    
    private let privateKey = P256.KeyAgreement.PrivateKey()
    
    public func generateExchangeKey() -> ExchangeKey {
        return ExchangeKey(
            publicKey: privateKey.publicKey.rawRepresentation,
            privateKey: privateKey.rawRepresentation
        )
    }
    
    public func generateSecureKey(data: SecureKey) throws -> Data {
        let privateKey = try PrivateKey(rawRepresentation: data.privateKey)
        let publicKey = try PublicKey(rawRepresentation: data.publicKey)
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        let key = sharedSecret.hkdfDerivedSymmetricKey(using: data.hashFunction, salt: data.salt, sharedInfo: data.sharedInfo, outputByteCount: data.outputByteCount)
        return key.withUnsafeBytes { Data($0) }
    }
}
