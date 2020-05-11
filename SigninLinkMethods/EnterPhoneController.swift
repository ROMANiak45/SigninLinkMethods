//
//  EnterPhoneController.swift
//  SigninLinkMethods
//
//  Created by Roman Croitor on 07/05/2020.
//  Copyright © 2020 Roman Croitor. All rights reserved.
//

import UIKit

class EnterPhoneController: UIViewController {
    
    fileprivate let registrationModel = RegistrationModel()
    
    fileprivate let phoneLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Enter you phone number below\nor leave the test number below"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    fileprivate let phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type your phone number here"
        textField.text = "+16505551234"
        textField.keyboardType = .phonePad
        textField.returnKeyType = .continue
        textField.backgroundColor = .white
        textField.textContentType = .telephoneNumber
        textField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        textField.textAlignment = .center
        return textField
    }()
    fileprivate let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .cyan
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handlePhoneSignin), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    fileprivate func setupLayout() {
        view.backgroundColor = .systemGray6
        
        [phoneLabel, phoneNumberTextField, continueButton].forEach { (object) in
            view.addSubview(object)
        }
        
        phoneLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 64, left: 32, bottom: 0, right: 32))
        phoneNumberTextField.anchor(top: phoneLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 32, left: 32, bottom: 0, right: 32))
        continueButton.anchor(top: phoneNumberTextField.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 32, left: 32, bottom: 0, right: 32))
    }
    
    @objc fileprivate func handlePhoneSignin() {
        registrationModel.enterPhoneNumber(phoneNumberTextField.text) { (error) in
            if let error = error {
                print("Failed to register with error: ", error)
                return
            }
        }
    }
}
