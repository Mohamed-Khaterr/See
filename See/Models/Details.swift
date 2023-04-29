//
//  DetailMovieResponse.swift
//  See
//
//  Created by Khater on 10/20/22.
//

import Foundation

// Can Be Movie or TV Show
struct Details: Decodable {
    
    struct Genre: Decodable{
        let id: Int
        let name: String
    }
    
    let id: Int
    let overview: String
    let genres: [Genre]
    let posterPath: String?
    let backdropPath: String?
    let popularity: Double
    let rate: Double
    let ratedCount: Int
    
    // Movie
    let title: String?
    let releaseDate: String?
    
    
    // TV Show
    let name: String?
    let firstAirDate: String?
    let numberOfEpisodes: Int?
    let numberOfSeasons: Int?
    

    enum CodingKeys: String, CodingKey {
        case id, title, name, overview, genres, popularity
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case rate = "vote_average"
        case ratedCount = "vote_count"
    }
    
    
    var safeTitle: String {
        // title for Movie || name for TV Show
        return title ?? name ?? "No Title!"
    }
    
    var safeReleaseDate: String {
        return releaseDate ?? firstAirDate ?? "No Release Date!"
    }

    var releaseYear: String {
        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "yy-MM-dd"

        // releaseDate if the object is Movie
        // firstAirDate if the objcet is TV
        let stringDate = releaseDate ?? firstAirDate ?? ""
        
        // Convert String to Date
        guard let date = dateFormatter.date(from: stringDate) else {
            // stringDate is Empty
            print("Error! *Show Struct*: \nreleaseYear variable: \(stringDate)")
            return "No Release Date!"
        }

        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: date)

        // Final Result Release Year
        return yearString
    }
    
    var genreString: String {
        var temp = ""
        for genre in genres {
            temp += (temp == "") ? genre.name : ", \(genre.name)"
        }
        return temp
    }
}
