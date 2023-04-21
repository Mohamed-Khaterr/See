//
//  CastResponse.swift
//  See
//
//  Created by Khater on 10/21/22.
//

import Foundation


struct CastResponse: Decodable{
    let id: Int
    let cast: [Cast]
}


struct Cast: Decodable{
    let id: Int
    let order: Int
    let name: String
    let popularity: Double
    let department: String
    let character: String?
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, order, name, popularity
        case department = "known_for_department"
        case character
        case profilePath = "profile_path"
    }
    
    var identifier: String {
        return String(id) + name
    }
}
