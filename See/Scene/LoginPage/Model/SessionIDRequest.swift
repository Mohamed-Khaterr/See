//
//  SessionIDRequest.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation


struct SessionIDRequest: Encodable{
    let requestToken: String
    
    enum CodingKeys: String, CodingKey{
        case requestToken = "request_token"
    }
}
