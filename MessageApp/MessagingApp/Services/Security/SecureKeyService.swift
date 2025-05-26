//
//  SecureKeyService.swift
//  MessagingApp
//
//  Created by Sam on 25/5/25.
//

import Foundation
public protocol SecureKeyService<KeyData> {
    associatedtype KeyData
    func generatePublicKey() -> Data
    func generateKey(data: KeyData) throws -> Data
}

import CryptoKit

public struct P256KeyData {
    let encryptKey: Data
    let decryptKey: Data
    let salt: any DataProtocol
    let hashFunction: any HashFunction.Type
    let sharedInfo: any DataProtocol
    let outputByteCount: Int
}

public final class P256SecureKeyService: SecureKeyService {
    typealias PublicKey = P256.KeyAgreement.PublicKey
    typealias PrivateKey = P256.KeyAgreement.PrivateKey
    public typealias KeyData = P256KeyData
    
    private let privateKey = P256.KeyAgreement.PrivateKey()
    
    public func generatePublicKey() -> Data {
        return privateKey.publicKey.rawRepresentation
    }
    
    public func generateKey(data: KeyData) throws -> Data {
        let privateKey = try PrivateKey(rawRepresentation: data.encryptKey)
        let publicKey = try PublicKey(rawRepresentation: data.decryptKey)
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        let key = sharedSecret.hkdfDerivedSymmetricKey(using: data.hashFunction, salt: data.salt, sharedInfo: data.sharedInfo, outputByteCount: data.outputByteCount)
        return key.withUnsafeBytes { Data($0) }
    }
}
