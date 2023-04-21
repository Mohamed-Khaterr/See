//
//  Status.swift
//  See
//
//  Created by Khater on 11/2/22.
//

import Foundation


struct Status: Decodable{
    let id: Int
    let favorite: Bool
    let watchlist: Bool
    var rated: Bool
    
    enum CodingKeys: String, CodingKey{
        case id, favorite, watchlist, rated
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        
        id = try container.decode(Int.self, forKey: .id)
        favorite = try container.decode(Bool.self, forKey: .favorite)
        watchlist = try container.decode(Bool.self, forKey: .watchlist)
        
        if let rated = try? container.decode(Bool.self, forKey: .rated) {
            self.rated = rated
        }else{
            self.rated = true
        }
    }
}
