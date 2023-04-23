//
//  Video.swift
//  See
//
//  Created by Khater on 10/22/22.
//

import Foundation


struct VideosResponse: Decodable{
    let id: Int
    let results: [Video]
}

struct Video: Decodable{
    
    enum Site: String, Codable {
        case youTube = "YouTube"
        case vimeo = "Vimeo"
    }

    let id: String
    let name: String
    let key: String
    let site: Site
    // type is Featurette or Behind the Scenes or Clip or Trailer or Teaser
    let type: String
    let official: Bool
    let publishedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, key, site, type, official
        case publishedAt = "published_at"
    }
}


/*
Trailer URL
Just add the Key in the respective URL:
YouTube: https://www.youtube.com/watch?v=
Vimeo: https://vimeo.com/
*/
