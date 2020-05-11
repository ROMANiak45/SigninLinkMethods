//
//  RegisterView.swift
//  SigninLinkMethods
//
//  Created by Roman Croitor on 05/05/2020.
//  Copyright © 2020 Roman Croitor. All rights reserved.
//

import UIKit
import AuthenticationServices

class RegisterView: UIStackView {
    let topLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    let fbSigninButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("FACEBOOK SIGN IN", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        return button
    }()
    let phoneSigninButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("PHONE SIGN IN", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .cyan
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        return button
    }()
    let appleSigninButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    let signOutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("SIGN OUT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .red
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    fileprivate func setupLayout() {
        backgroundColor = .white
        [topLabel, fbSigninButton, phoneSigninButton, appleSigninButton, signOutButton].forEach { (button) in
            addArrangedSubview(button)
        }
        axis = .vertical
        spacing = 16
        distribution = .fillEqually
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
