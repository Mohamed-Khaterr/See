//
//  TMDBErrorResponse.swift
//  See
//
//  Created by Khater on 3/25/23.
//

import Foundation


struct TMDBErrorResponse: Decodable {
    let success: Bool
    let errors: [String]
}

extension TMDBErrorResponse: LocalizedError {
    var errorDescription: String? {
        return errors.joined(separator: " | ")
    }
}
