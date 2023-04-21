//
//  MarkAsFavorite.swift
//  See
//
//  Created by Khater on 11/2/22.
//

import Foundation


struct MarkFavorite: Encodable{
    let type: String
    let id: Int
    let favorite: Bool
    
    enum CodingKeys: String, CodingKey{
        case type = "media_type"
        case id = "media_id"
        case favorite
    }
}
