//
//  AccountStates.swift
//  See
//
//  Created by Khater on 11/2/22.
//

import Foundation


struct AccountStates: Decodable{
    let id: Int
    let favorite: Bool
    let watchlist: Bool
    let rated: Bool
    
    enum CodingKeys: String, CodingKey{
        case id, favorite, watchlist, rated
    }
    
    init(){
        id = 0
        favorite = false
        watchlist = false
        rated = false
    }
    
    // rated variable response can be Bool or it can be Object {value:"5.0"}
    // this initializer prevent from errors
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        favorite = try container.decode(Bool.self, forKey: .favorite)
        watchlist = try container.decode(Bool.self, forKey: .watchlist)
        
        if let rated = try? container.decode(Bool.self, forKey: .rated) {
            // rated variable is of type Bool
            self.rated = rated
        }else{
            // rated variable is of type Object{value:"5.0"}
            self.rated = true
        }
    }
}
