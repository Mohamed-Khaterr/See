//
//  DeleteSessionRequest.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation

// Delete Session Request
struct LogoutRequest: Encodable{
    let sessionId: String
    
    enum CodingKeys: String, CodingKey{
        case sessionId = "session_id"
    }
}
