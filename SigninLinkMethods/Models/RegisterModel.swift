//
//  RegisterModel.swift
//  SigninLinkMethods
//
//  Created by Roman Croitor on 08/05/2020.
//  Copyright © 2020 Roman Croitor. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import CryptoKit
import AuthenticationServices

class RegistrationModel {
    
    fileprivate let db = Firestore.firestore()
    fileprivate let previousUser = Auth.auth().currentUser
    
    fileprivate var facebookAuthCredential: AuthCredential?
    fileprivate var phoneAuthCredential: AuthCredential?
    fileprivate var verificationId: String?
    fileprivate var appleAuthCredential: AuthCredential?
    fileprivate var currentNonce: String?
    
    // MARK: -Signin With Facebook
    func signinWithFacebook(_ view: UIViewController, completion: @escaping (Error?) -> ()) {
        LoginManager().logIn(permissions: ["email", "public_profile"], from: view) { [unowned self] (result, error) in
            if let error = error {
                print("Failed to get FB auth: ", error.localizedDescription)
                completion(error)
                return
            } else if result!.isCancelled {
                print("FBLogin cancelled")
            } else {
                guard let accessToken = AccessToken.current else { return }
                print("FB auth token is: ", accessToken.tokenString)
                
                self.facebookAuthCredential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                
                self.performRegistration(self.facebookAuthCredential, completion: completion)
            }
        }
    }
    
    // MARK: -Signin With Phone
    func enterPhoneNumber(_ phoneNumber: String?, completion: @escaping (Error?) -> ()) {
        guard let phoneNumber = phoneNumber else { return }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
            if let error = error {
                print("Failed to get phone auth: ", error.localizedDescription)
                completion(error)
                return
            }
            
            print("<<<<<<<<<<<<<<<< Phone verification ID is ........", verificationId as Any)
            self.verificationId = verificationId
            completion(nil)
        }
    }
    
    func confirmPhoneNumber(_ verificationCode: String?, completion: @escaping (Error?) -> ()) {
        guard let verificationId = verificationId else { return }
        guard let verificationCode = verificationCode else { return }
        phoneAuthCredential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
        performRegistration(phoneAuthCredential, completion: completion)
    }
    
    //MARK: -Signin With Apple
    
    @available(iOS 13, *)
        func startSignInWithAppleFlow() -> [ASAuthorizationAppleIDRequest] {
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            return [request]
        }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    func handleAppleSingin(_ authorization: ASAuthorization, completion: @escaping (Error?) -> ()) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // Sign in with Firebase.
            performRegistration(credential, completion: completion)
        }
    }
    
    //MARK: -Register User in Firebase
    fileprivate func performRegistration(_ credential: AuthCredential?, completion: @escaping (Error?) -> ()) {
        print("<<<<<<<<< previousUser is: ", previousUser as Any)
        guard let credential = credential else { return }
        Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                print("Failed to signin with facebook: ", error.localizedDescription)
                if let previousUser = self.previousUser {
                    self.linkUserToExistingAccount(previousUser, credential, completion: completion)
                } else {
                    completion(error)
                    return
                }
            }
            
            guard let userID = Auth.auth().currentUser?.uid else { return }
            let userDatabaseId = self.db.collection("USERS").document(userID)
            userDatabaseId.getDocument(completion: {  (document, error) in
                if let document = document, document.exists {
                    print("<<<<< Document data.... >>>>>,        GO TO SUCCESS", document.data().map(String.init(describing:)) ?? "nil")
                    completion(nil)
                } else {
                    print("<<<<<< Document does not exist.... >>>>>>>,   GO TO PHONE")
                    completion(nil)
                }
            })
        }
    }
    
    fileprivate func linkUserToExistingAccount(_ previousUser: User, _ credential: AuthCredential, completion: @escaping (Error?) -> ()) {
        previousUser.link(with: credential) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
                return
            }
            
        }
    }
    
    func handleSignOutUser(completion: @escaping (Error?) -> ()) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            LoginManager().logOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
