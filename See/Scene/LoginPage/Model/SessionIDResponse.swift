//
//  SessionIdResponse.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation


struct SessionIDResponse: Decodable{
    let success: Bool
    let sessionId: String
    
    enum CodingKeys: String, CodingKey{
        case success
        case sessionId = "session_id"
    }
}
