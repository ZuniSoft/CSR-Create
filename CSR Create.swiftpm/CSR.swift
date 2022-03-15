//
//  CSR.swift
//  CSR Create
//
//  Copyright © 2022 Keith R. Davis
//

import Foundation
import CryptoKit
import CertificateSigningRequest

class CSR {
    func Create(commonName: String,
                organizationName: String,
                organizationUnitName: String,
                countryName: String,
                stateOrProvinceName: String,
                localityName: String,
                emailAddress: String,
                description: String,
                format: String,
                keySize: String,
                sigType: String) -> String {
        
        let tagPrivate = "com.zunisoft.csr.private.rsa"
        let tagPublic = "com.zunisoft.csr.public.rsa"
        
        var keyAlgorithm = KeyAlgorithm.rsa(signatureType: .sha1)
        
        if sigType == "sha1" {
            keyAlgorithm = KeyAlgorithm.rsa(signatureType: .sha1)
        } else if sigType == "sha256" {
            keyAlgorithm = KeyAlgorithm.rsa(signatureType: .sha256)
        } else if sigType == "sha512" {
            keyAlgorithm = KeyAlgorithm.rsa(signatureType: .sha512)
        }
        
        let sizeOfKey = Int(keySize)! //keyAlgorithm.availableKeySizes.last!

        var csrFinal = ""
        
        let (potentialPrivateKey, potentialPublicKey) =
        self.generateKeysAndStoreInKeychain(keyAlgorithm,
                                            keySize: sizeOfKey,
                                            tagPrivate: tagPrivate,
                                            tagPublic: tagPublic)
        
        guard let privateKey = potentialPrivateKey,
              let publicKey = potentialPublicKey else {
                  if potentialPrivateKey == nil {
                      print("Private key not generated")
                  }
                  if potentialPublicKey == nil {
                      print("Public key not generated")
                  }
                  return "Error: private or public key not created" 
              }

        let (potentialPublicKeyBits, potentialPublicKeyBlockSize) =
        self.getPublicKeyBits(keyAlgorithm,
                              publicKey: publicKey,
                              tagPublic: tagPublic)
        guard let publicKeyBits = potentialPublicKeyBits,
              potentialPublicKeyBlockSize != nil else {
                  return "Error: private key bits not generated"
              }

        //Initiale CSR
        let csr = CertificateSigningRequest(commonName: commonName,
                                            organizationName: organizationName,
                                            organizationUnitName: organizationUnitName,
                                            countryName: countryName,
                                            stateOrProvinceName: stateOrProvinceName,
                                            localityName: localityName,
                                            emailAddress: emailAddress,
                                            description: description,
                                            keyAlgorithm: keyAlgorithm)
        //Build the CSR
        let csrBuild = csr.buildAndEncodeDataAsString(publicKeyBits, privateKey: privateKey)
        let csrBuild2 = csr.buildCSRAndReturnString(publicKeyBits, privateKey: privateKey)
        if format == "Without Headers" {
            if let csrRegular = csrBuild {
                csrFinal = csrRegular
            } else {
                if csrBuild == nil {
                    csrFinal = "Error: CSR without header not generated"
                }
            }
        } else {
            if let csrWithHeaderFooter = csrBuild2 {
                csrFinal = csrWithHeaderFooter
            } else {
                if csrBuild2 == nil {
                    csrFinal = "Error: CSR with header not generated"
                }
            }
        }
        return csrFinal
    }
    
    private func generateKeysAndStoreInKeychain(_ algorithm: KeyAlgorithm, keySize: Int,
                                        tagPrivate: String, tagPublic: String) -> (SecKey?, SecKey?) {
        ////////////////
        let my_query: [String: Any] = [
            String(kSecClass): kSecClassKey,
            String(kSecAttrKeyType): algorithm.secKeyAttrType,
            String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
            String(kSecReturnRef): true
        ]
        SecItemDelete(my_query as CFDictionary)
        ////////////////
        
        let publicKeyParameters: [String: Any] = [
            String(kSecAttrIsPermanent): true,
            String(kSecAttrAccessible): kSecAttrAccessibleAfterFirstUnlock,
            String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!
        ]
        
        var privateKeyParameters: [String: Any] = [
            String(kSecAttrIsPermanent): true,
            String(kSecAttrAccessible): kSecAttrAccessibleAfterFirstUnlock,
            String(kSecAttrApplicationTag): tagPrivate.data(using: .utf8)!
        ]
        
#if !targetEnvironment(simulator)
        //This only works for Secure Enclave consistign of 256 bit key,
        //note, the signatureType is irrelavent for this check
        if algorithm.type == KeyAlgorithm.ec(signatureType: .sha1).type {
            let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                         kSecAttrAccessibleAfterFirstUnlock,
                                                         .privateKeyUsage,
                                                         nil)!   // Ignore error
            privateKeyParameters[String(kSecAttrAccessControl)] = access
        }
#endif
        //Define what type of keys to be generated here
        var parameters: [String: Any] = [
            String(kSecAttrKeyType): algorithm.secKeyAttrType,
            String(kSecAttrKeySizeInBits): keySize,
            String(kSecReturnRef): true,
            String(kSecPublicKeyAttrs): publicKeyParameters,
            String(kSecPrivateKeyAttrs): privateKeyParameters
        ]
        
#if !targetEnvironment(simulator)
        //iOS only allows EC 256 keys to be secured in enclave.
        //This will attempt to allow any EC key in the enclave,
        //assuming iOS will do it outside of the enclave if it
        //doesn't like the key size, note: the signatureType is irrelavent for this check
        if algorithm.type == KeyAlgorithm.ec(signatureType: .sha1).type {
            parameters[String(kSecAttrTokenID)] = kSecAttrTokenIDSecureEnclave
        }
#endif
        
        //Use Apple Security Framework to generate keys, save them to application keychain
        var error: Unmanaged<CFError>?
        let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error)
        if privateKey == nil {
            print("Error creating keys occured: \(error!.takeRetainedValue() as Error), keys weren't created")
            return (nil, nil)
        }
        
        //Get generated public key
        let query: [String: Any] = [
            String(kSecClass): kSecClassKey,
            String(kSecAttrKeyType): algorithm.secKeyAttrType,
            String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
            String(kSecReturnRef): true
        ]
        
        var publicKeyReturn: CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &publicKeyReturn)
        if result != errSecSuccess {
            print("Error getting publicKey fron keychain occured: \(result)")
            return (privateKey, nil)
        }
        // swiftlint:disable:next force_cast
        let publicKey = publicKeyReturn as! SecKey?
        return (privateKey, publicKey)
    }
    
    private func getPublicKeyBits(_ algorithm: KeyAlgorithm, publicKey: SecKey, tagPublic: String) -> (Data?, Int?) {
        
        //Set block size
        let keyBlockSize = SecKeyGetBlockSize(publicKey)
        //Ask keychain to provide the publicKey in bits
        let query: [String: Any] = [
            String(kSecClass): kSecClassKey,
            String(kSecAttrKeyType): algorithm.secKeyAttrType,
            String(kSecAttrApplicationTag): tagPublic.data(using: .utf8)!,
            String(kSecReturnData): true
        ]
        
        var tempPublicKeyBits: CFTypeRef?
        var _ = SecItemCopyMatching(query as CFDictionary, &tempPublicKeyBits)
        
        guard let keyBits = tempPublicKeyBits as? Data else {
            return (nil, nil)
        }
        
        return (keyBits, keyBlockSize)
    }
}
