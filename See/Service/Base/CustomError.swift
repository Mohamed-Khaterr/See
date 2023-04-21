//
//  CustomError.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import Foundation



enum CustomError: LocalizedError {
    case noResponse
    case serverError
    case noData
    case noConnection
    case TMDBMessage(message: String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .noResponse: return "Well, weird thing happens on the Server, The server is not response at this time please try again!"
        case .serverError: return "Sorry, Server is not working right now please try again later!"
        case .noData: return "Well, weird thing happens!"
        case .noConnection: return "No Internet Connection"
        case .TMDBMessage(let message): return message
        case .decodingError: return "Sorry, weird thing happens!"
        }
    }
}
