//
//  ViewController.swift
//  SigninLinkMethods
//
//  Created by Roman Croitor on 05/05/2020.
//  Copyright © 2020 Roman Croitor. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import JGProgressHUD
import AuthenticationServices

class RegisterController: UIViewController {
    
    fileprivate let db = Firestore.firestore()
    fileprivate let registrationModel = RegistrationModel()
    fileprivate var currentNonce: String?
    
    fileprivate let registerView = RegisterView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        addButtonTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        checkUser()
    }

    fileprivate func setupLayout() {
        view.backgroundColor = .white
        
        view.addSubview(registerView)
        registerView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 32, bottom: 0, right: 32))
        registerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func addButtonTargets() {
        registerView.fbSigninButton.addTarget(self, action: #selector(handleFBSignin), for: .touchUpInside)
        registerView.phoneSigninButton.addTarget(self, action: #selector(handlePhoneSignin), for: .touchUpInside)
        registerView.appleSigninButton.addTarget(self, action: #selector(handleAppleSingin), for: .touchUpInside)
        registerView.signOutButton.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
    }
    
    fileprivate func checkUser() {
        if let _ = Auth.auth().currentUser {
            registerView.topLabel.text = "User is logged in"
        } else {
            registerView.topLabel.text = "User is logged out"
        }
    }
    
    @objc fileprivate func handleFBSignin() {
        registrationModel.signinWithFacebook(self) { [unowned self] (error) in
            if let error = error {
                print("Failed to register with error: ", error)
                return
            }
            let enterPhoneController = EnterPhoneController()
            self.navigationController?.pushViewController(enterPhoneController, animated: true)
        }
    }
    
    @objc fileprivate func handlePhoneSignin() {
        let enterPhoneController = EnterPhoneController()
        navigationController?.pushViewController(enterPhoneController, animated: true)
    }
    
    @objc fileprivate func handleAppleSingin() {
        let requests = registrationModel.startSignInWithAppleFlow()
        currentNonce = requests.first?.nonce
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc fileprivate func handleSignOut() {
        registrationModel.handleSignOutUser { [unowned self] (error) in
            if let error = error {
                print("Failed to sign out user: ", error.localizedDescription)
                return
            }
            self.checkUser()
        }
    }
}

extension RegisterController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension RegisterController: ASAuthorizationControllerDelegate {
    // Handle authorization success
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        registrationModel.handleAppleSingin(authorization) { [unowned self] (error) in
            if let error = error {
                print("Failed to signin with Apple ID: ", error.localizedDescription)
                return
            }
            self.checkUser()
        }
    }

    // Handle authorization failure
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}
