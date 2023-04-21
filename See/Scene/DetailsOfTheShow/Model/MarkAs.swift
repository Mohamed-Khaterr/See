//
//  MarkAs.swift
//  See
//
//  Created by Khater on 3/25/23.
//

import Foundation

struct MarkAs: Encodable {
    let favorite: Bool?
    let watchlist: Bool?
    let type: String
    let id: Int
    
    enum CodingKeys: String, CodingKey{
        case type = "media_type"
        case id = "media_id"
        case favorite
        case watchlist
    }
}
