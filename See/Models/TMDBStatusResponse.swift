//
//  TMDBStatusResponse.swift
//  See
//
//  Created by Khater on 10/19/22.
//

import Foundation


/// It can be response object or error object
struct TMDBStatusResponse: Decodable{
    let success: Bool
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey{
        case success
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}


extension TMDBStatusResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}
