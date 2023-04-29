//
//  Show.swift
//  See
//
//  Created by Khater on 10/20/22.
//

import Foundation

struct ShowResponse: Decodable {
    let page: Int
    let results: [Show]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}


// MARK: - Show
// Show is Movie or TV Show
struct Show: Decodable{
    let id: Int
    let overview: String
    let genreIDS: [Int]
    let popularity: Double
    let rate: Double
    let rateCount: Int

    // Image
    let backdropPath: String?
    let posterPath: String?

    // Movie
    let title: String?
    let releaseDate: String? // 2022-12-28

    // TV
    let name: String?
    let firstAirDate: String? // 2019-01-01

    // Other
    let type: ShowType?


    enum CodingKeys: String, CodingKey {
        case id, overview, popularity
        case genreIDS = "genre_ids"
        case rate = "vote_average"
        case rateCount = "vote_count"

        // Image
        case backdropPath = "backdrop_path"
        case posterPath = "poster_path"

        // Movie
        case title
        case releaseDate = "release_date"

        // TV Show
        case name
        case firstAirDate = "first_air_date"

        // Other
        case type = "media_type"
    }
    
    
    // MARK: Computed Properties
    var identifier: String {
        return String(id) + (title ?? name ?? "Nil")
    }

    var safeTitle: String {
        // title for Movie || name for TV Show
        return title ?? name ?? "No Title!"
    }
    
    var genreString: String{
        var genresStringArray: [String] = []
        
        for id in genreIDS {
            guard let genre = TMDB.genres.first(where: { $0.id == id }) else { continue }
            genresStringArray.append(genre.name)
        }
        
        let genreString = genresStringArray.joined(separator: ", ")
        return genreString
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
    
    var safeTypeString: String {
        return type?.rawValue ?? "Type is not specified"
    }
}
