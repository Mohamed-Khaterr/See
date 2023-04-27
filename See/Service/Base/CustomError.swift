//
//  CustomError.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import Foundation



enum CustomError: LocalizedError {
    case noResponse
    case noData
    case decodingError
    case noLogin(customMessage: String? = nil)
    
    var errorDescription: String? {
        switch self {
        case .noResponse: return "Well, weird thing happens on the Server, The server is not response at this time please try again!"
        case .noData: return "No response from the server, please try again later!"
        case .decodingError: return "Sorry, weird thing happens!"
        case .noLogin(let customMessage): return customMessage ?? "You are not logged in, please login and try again."
        }
    }
}
