//
//  ValidateWithLoginRequest.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation


struct LoginRequest: Encodable{
    let username: String
    let password: String
    let requestToken: String
    
    enum CodingKeys: String,CodingKey{
        case username
        case password
        case requestToken = "request_token"
    }
}
