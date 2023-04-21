//
//  Filter.swift
//  See
//
//  Created by Khater on 4/6/23.
//

import Foundation


struct Filter {
    var sort: TMDB.Sort?
    var genresID: [Int] = []
    var rate: Int?
    var releaseYear: Int?
}
