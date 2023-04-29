//
//  Media.swift
//  See
//
//  Created by Khater on 11/2/22.
//

import Foundation


struct TMDB{
    
    
    private init() {}
    
    struct Genre {
        let id: Int
        let name: String
    }
    
    static let genres: [Genre] = [
        Genre(id: 12, name: "Adventure"),
        Genre(id: 14, name: "Fantasy"),
        Genre(id: 16, name: "Animation"),
        Genre(id: 18, name: "Drama"),
        Genre(id: 27, name: "Horror"),
        Genre(id: 28, name: "Action"),
        Genre(id: 35, name: "Comedy"),
        Genre(id: 36, name: "History"),
        Genre(id: 37, name: "Western"),
        Genre(id: 53, name: "Thriller"),
        Genre(id: 80, name: "Crime"),
        Genre(id: 99, name: "Documentary"),
        Genre(id: 878, name: "Science Fiction"),
        Genre(id: 9648, name: "Mystery"),
        Genre(id: 10402, name: "Music"),
        Genre(id: 10749, name: "Romance"),
        Genre(id: 10751, name: "Family"),
        Genre(id: 10752, name: "War"),
        Genre(id: 10759, name: "Action & Adventure"),
        Genre(id: 10762, name: "Kids"),
        Genre(id: 10763, name: "News"),
        Genre(id: 10764, name: "Reality"),
        Genre(id: 10765, name: "Sci-Fi & Fantasy"),
        Genre(id: 10766, name: "Soap"),
        Genre(id: 10767, name: "Talk"),
        Genre(id: 10768, name: "War & Politics"),
        Genre(id: 10770, name: "TV Movie")
    ]
    
    
    enum Sort: String{
        case popularityAsc = "popularity.asc"
        case popularityDesc = "popularity.desc"
        case releaseDateDesc = "release_date.desc"
        case releaseDateAsc = "release_date.asc"
        case revenueAsc = "revenue.asc"
        case revenueDesc = "revenue.desc"
        case primaryReleaseDateAsc = "primary_release_date.asc"
        case primaryReleaseDateDesc = "primary_release_date.desc"
        case originalTitleAsc = "original_title.asc"
        case originalTitleDesc = "original_title.desc"
        case voteAverageAsc = "vote_average.asc"
        case voteAverageDesc = "vote_average.desc"
        case voteCountAsc = "vote_count.asc"
        case voteCountDesc = "vote_count.desc"
    }
    
    
    
    enum TimeWindow: String{
        case day = "day"
        case week = "week"
    }
    
}
