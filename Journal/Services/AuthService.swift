//
//  AuthService.swift
//  Journal
//
//  Created by Kerby Jean on 4/29/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import CryptoKit

class AuthService {
    
    static let shared = AuthService()
    
    typealias completion = Result<Any?, Error>
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func signIn(idTokenString: String, nonce: String, givenName: String?, email: String, completion: @escaping (completion) -> Void) {
        // Initialize a Firebase credential.
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            
            let changeRequest = result?.user.createProfileChangeRequest()
            changeRequest?.displayName = givenName
            
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    guard let user = result?.user else { return }
                    completion(.success(user))
                }
            })
        }
    }
}
