//
//  User.swift
//  Wordy
//
//  Created by user on 16.02.2024.
//

import Foundation

enum AuthType: Codable {
    case Email, AppleID
}

class User: Codable {
    let authType: AuthType
    
    var email: String?
    var password: String?
    
    var appleToken: String?
    var nonce: String?
    
    init(authType: AuthType, email: String? = nil, password: String? = nil, appleToken: String? = nil, nonce: String? = nil) {
        self.authType = authType
        self.email = email
        self.password = password
        self.appleToken = appleToken
        self.nonce = nonce
    }
}
