//
//  TMDBService.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import Foundation


final class TMDBService {
    
    func getTrending(_ type: [ShowType], timeIn: TMDB.TimeWindow) async throws -> [Show] {
        let typeString = (type.count > 1) ? "all" : type[0].rawValue
        let url = Endpoint.Trending.get(type: typeString, timeWindow: timeIn.rawValue).url
        
        do {
            let data = try await URLSession.shared.prefromTask(with: url, type: ShowResponse.self)
            let shows = data.results
            
            // Return Show that has Backdrop Image
            var showsWithBackdropImage: [Show] = []
            for show in shows {
                if show.backdropPath != nil {
                    showsWithBackdropImage.append(show)
                }
            }
            
            return showsWithBackdropImage
            
        } catch {
            throw error
        }
    }
    
    
    func getDiscover(_ type: ShowType, page: Int = 1, sortBy: TMDB.Sort? = .popularityDesc, year: Int? = nil, genreIDs: [Int] = [], rating: Double? = nil) async throws -> [Show] {
        let url: URL!
        switch type {
        case .movie:
            url = Endpoint.Discover.movie(page: page, sortBy: sortBy, year: year, genreIDs: genreIDs, rating: rating).url
        case .tv:
            url = Endpoint.Discover.tv(page: page, sortBy: sortBy, year: year, genreIDs: genreIDs, rating: rating).url
        }
        
        do {
            let data = try await URLSession.shared.prefromTask(with: url, type: ShowResponse.self)
            return data.results
            
        } catch {
            throw error
        }
    }
    
    
    
    
    func getDetailsOfTheShow(id: Int, type: ShowType) async throws -> Details {
        let url: URL!
        
        switch type {
        case .movie:
            url = Endpoint.Movie.details(id: id).url
        case .tv:
            url = Endpoint.TV.details(id: id).url
        }
        
        do {
            let result = try await URLSession.shared.prefromTask(with: url, type: Details.self)
            return result
            
        } catch {
            throw error
        }
    }
    
    
    func getTrailerVideoPaths(forID id: Int, andType type: ShowType) async throws -> [Video] {
        let url: URL!
        switch type {
        case .movie:
            url = Endpoint.Movie.videos(id: id).url
        case .tv:
            url = Endpoint.TV.videos(id: id).url
        }
        
        do {
            let trailerVideosResponse = try await URLSession.shared.prefromTask(with: url, type: VideosResponse.self)
            return trailerVideosResponse.results
        } catch {
            throw error
        }
    }
    
    
    func getCast(forShowID id: Int, type: ShowType) async throws -> [Cast] {
        let url: URL!
        switch type {
        case .movie:
            url = Endpoint.Movie.cast(id: id).url
        case .tv:
            url = Endpoint.TV.cast(id: id).url
        }
        
        do {
            let result = try await URLSession.shared.prefromTask(with: url, type: CastResponse.self)
            return result.cast
            
        } catch {
            throw error
        }
    }
    
    
    func getSimilarShows(forID id: Int, type: ShowType) async throws -> [Show] {
        let url: URL!
        switch type {
        case .movie:
            url = Endpoint.Movie.similar(id: id).url
        case .tv:
            url = Endpoint.TV.similar(id: id).url
        }
        
        do {
            let similarShows = try await URLSession.shared.prefromTask(with: url, type: ShowResponse.self)
            return similarShows.results
        } catch {
            throw error
        }
    }
    
    
    func search(_ text: String, in type: ShowType, page: Int) async throws -> [Show] {
        let url: URL!
        switch type {
        case .movie:
            url = Endpoint.Search.movie(title: text, page: page).url
        case .tv:
            url = Endpoint.Search.tv(name: text, page: page).url
        }
        
        do {
            let search = try await URLSession.shared.prefromTask(with: url, type: ShowResponse.self)
            return search.results
            
        } catch {
            throw error
        }
    }
    
    func rate(_ type: ShowType, id: Int, markAsRate: Bool, forUserSessionID sessionID: String, accountID: Int) async throws {
        let url: URL
        switch type {
        case .movie:
            url = Endpoint.Movie.rate(id: id, sessionID: sessionID).url
        case .tv:
            url = Endpoint.TV.rate(id: id, sessionID: sessionID).url
        }
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if markAsRate {
            request.httpMethod = "POST"
            request.httpBody = try! JSONSerialization.data(withJSONObject: ["value": 5], options: .fragmentsAllowed)
            
        } else {
            request.httpMethod = "DELETE"
        }
        
        do {
            let status = try await URLSession.shared.prefromTask(with: request, type: TMDBStatusResponse.self)
            
            if !status.success {
                throw status
            }
            
        } catch {
            throw error
        }
    }
    
    
    func getAccountStates(_ type: ShowType, id: Int, forUserSessionID sessionID: String) async throws -> AccountStates {
        let url: URL!
        switch type {
        case .movie:
            url = Endpoint.Movie.getStatus(id: id, sessionID: sessionID).url
        case .tv:
            url = Endpoint.TV.getStatus(id: id, sessionID: sessionID).url
        }
        
        do {
            let status = try await URLSession.shared.prefromTask(with: url, type: AccountStates.self)
            return status
            
        } catch {
            throw error
        }
    }
}
