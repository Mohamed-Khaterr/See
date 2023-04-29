//
//  AccountInfoResponse.swift
//  See
//
//  Created by Khater on 11/2/22.
//

import Foundation


struct Account: Decodable{
    let avatar: Avatar
    let id: Int
    let name: String
    let username: String
}

struct Avatar: Decodable{
    let gravatar: GrAvatar
    let tmdb: TMDBAvatar
}

struct GrAvatar: Decodable{
    let hash: String
}

struct TMDBAvatar: Decodable{
    let avatarPath: String?
    
    enum CodingKeys: String, CodingKey{
        case avatarPath = "avatar_path"
    }
}
