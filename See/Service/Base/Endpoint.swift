//
//  Endpoint.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import Foundation



enum Endpoint {
    
    private static func getURL(for path: String, query queryItems: [URLQueryItem]) -> URL {
        // https://api.themoviedb.org/3
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.themoviedb.org"
        urlComponents.path = "/3" + path
        urlComponents.queryItems = queryItems
        urlComponents.queryItems?.append(URLQueryItem(name: "api_key", value: Hidden.apiKey))
        return urlComponents.url!
    }
    
    
    // MARK: - Account
    enum Auth {
        case requestToken
        case requestSessionID
        case websiteLogin(token: String)
        case login
        case logout
        
        private var components: (path: String, query: [URLQueryItem]) {
            switch self {
            case .requestToken:
                return ("/token/new", [])
            case .requestSessionID:
                return ("/session/new", [])
            case .websiteLogin(let token):
                let query = URLQueryItem(name: "redirect_to", value: "\(Constant.appName):authenticate")
                return ("/\(token)", [query])
            case .login:
                return ("/token/validate_with_login", [])
            case .logout:
                return ("/session", [])
            }
        }
        
        public var url: URL {
            return Endpoint.getURL(for: "/authentication" + components.path, query: components.query)
        }
    }
    
    
    enum Account {
        case info(sessionID: String)
        case getFavorites(accountID: Int, type: String, sessionID: String)
        case markAsFavorite(accountID: Int, sessionID: String)
        case getWatchlist(accountID: Int, type: String, sessionID: String)
        case markAsWatchlist(accountID: Int, sessionID: String)
        
        private var components: (path: String, query: [URLQueryItem]) {
            switch self {
            case .info(let sessionID):
                let query = URLQueryItem(name: "session_id", value: sessionID)
                return ("", [query])
                
            case .getFavorites(let accountID, let type, let sessionID):
                let path = "/\(accountID)" + "/favorite" + "/\(type)"
                let query = URLQueryItem(name: "session_id", value: sessionID)
                return (path, [query])
                
            case .markAsFavorite(let accountID, let sessionID):
                let path = "/\(accountID)" + "/favorite"
                let query = URLQueryItem(name: "session_id", value: sessionID)
                return (path, [query])
                
            case .getWatchlist(let accountID, let type, let sessionID):
                let path = "/\(accountID)" + "/watchlist" + "/\(type)"
                let query = URLQueryItem(name: "session_id", value: sessionID)
                return (path, [query])
                
            case .markAsWatchlist(let accountID, let sessionID):
                let path = "/\(accountID)" + "/watchlist"
                let query = URLQueryItem(name: "session_id", value: sessionID)
                return (path, [query])
            }
        }
        
        public var url: URL {
            return Endpoint.getURL(for: "/account" + components.path, query: components.query)
        }
    }
    
    
    // MARK: - Image
    enum Image {
        private static let baseURL = "https://image.tmdb.org/t/p/"
        
        case get(inHeighQuality: Bool, path: String)
        
        private var path: String {
            switch self {
            case .get(let inHeighQuality, let path):
                let heighQuailtyPath = inHeighQuality ? "/original" : "/w500"
                return heighQuailtyPath + path
            }
        }
        
        public var url: URL {
            var urlComponents = URLComponents(string: "https://image.tmdb.org/t/p")!
            urlComponents.path += path
            return urlComponents.url!
        }
    }
    
    
    // MARK: - Discover
    enum Discover {
        case movie(page: Int?, sortBy: TMDB.Sort?, year: Int?, genreIDs: [Int] = [], rating: Double? = nil)
        case tv(page: Int?, sortBy: TMDB.Sort?, year: Int?, genreIDs: [Int] = [], rating: Double? = nil)
        
        private var components: (path: String, query: [URLQueryItem]) {
            switch self {
            case .movie(let page, let sort, let year, let genreIDs, let rating):
                let query = getQueryItems(page: page, sort: sort, year: year, genreIDs: genreIDs, rate: rating)
                return ("/movie", query)
                
            case .tv(let page, let sort, let year, let genreIDs, let rating):
                let query = getQueryItems(page: page, sort: sort, year: year, genreIDs: genreIDs, rate: rating)
                return ("/tv", query)
            }
        }
        
        
        private func getQueryItems(page: Int?, sort: TMDB.Sort?, year: Int?, genreIDs: [Int], rate: Double?) -> [URLQueryItem] {
            var quertItems: [URLQueryItem] = []
            if let page = page {
                quertItems.append(URLQueryItem(name: "page", value: String(page)))
            }
            
            if let sort = sort {
                quertItems.append(URLQueryItem(name: "sort_by", value: sort.rawValue))
            }
            
            if let year = year {
                quertItems.append(URLQueryItem(name: "with_release_type", value: "1"))
                quertItems.append(URLQueryItem(name: "year", value: String(year)))
            }
            
            if !genreIDs.isEmpty {
                var genereIDsString = ""
                for id in genreIDs {
                    genereIDsString += "\(id),"
                }
                quertItems.append(URLQueryItem(name: "with_genres", value: genereIDsString))
            }
            
            if let rating = rate {
                // lte -> less than or equal
                // gte -> greater than or equal
                quertItems.append(URLQueryItem(name: "vote_average.lte", value: String(rating)))
            }
            return quertItems
        }
        
        
        public var url: URL {
            return Endpoint.getURL(for: "/discover" + components.path, query: components.query)
        }
    }
    
    
    
    // MARK: - Trending
    enum Trending {
        case get(type: String, timeWindow: String)
        
        private var components: (path: String, query: [URLQueryItem]){
            switch self {
            case .get(type: let type, timeWindow: let timeWindow):
                let path = "/\(type)" + "/\(timeWindow)"
                return (path, [])
            }
        }
        
        public var url: URL {
            return Endpoint.getURL(for: "/trending" + components.path, query: components.query)
        }
    }
    
    
    // MARK: - Movie
    enum Movie {
        case topRated
        case details(id: Int)
        case cast(id: Int)
        case videos(id: Int)
        case similar(id: Int)
        case getStatus(id: Int, sessionID: String)
        case rate(id: Int, sessionID: String)
        
        private var components: (path: String, query: [URLQueryItem]) {
            switch self {
            case .topRated:
                return ("/top_rated", [])
                
            case .details(let id):
                return ("/\(id)", [])
                
            case .cast(let id):
                let path = "/\(id)" + "/credits"
                return (path, [])
                
            case .videos(let id):
                let path = "/\(id)" + "/videos"
                return (path, [])
                
            case .similar(let id):
                let path = "/\(id)" + "/similar"
                return (path, [])
                
            case .getStatus(id: let id, sessionID: let sessionID):
                let path = "/\(id)" + "/account_states"
                let queryItem = URLQueryItem(name: "session_id", value: sessionID)
                return (path, [queryItem])
                
            case .rate(id: let id, sessionID: let sessionID):
                let path = "/\(id)" + "/rating"
                let queryItem = URLQueryItem(name: "session_id", value: sessionID)
                return (path, [queryItem])
            }
        }
        
        public var url: URL {
            return Endpoint.getURL(for: "/movie" + components.path, query: components.query)
        }
    }
    
    
    // MARK: - TV
    enum TV {
        case topRated
        case details(id: Int)
        case cast(id: Int)
        case videos(id: Int)
        case similar(id: Int)
        case getStatus(id: Int, sessionID: String)
        case rate(id: Int, sessionID: String)
        
        private var components: (path: String, query: [URLQueryItem]) {
            switch self {
            case .topRated:
                return ("/top_rated", [])
                
            case .details(let id):
                return ("/\(id)", [])
                
            case .cast(let id):
                let path = "/\(id)" + "/credits"
                return (path, [])
                
            case .videos(let id):
                let path = "/\(id)" + "/videos"
                return (path, [])
                
            case .similar(let id):
                let path = "/\(id)" + "/similar"
                return (path, [])
                
            case .getStatus(id: let id, sessionID: let sessionID):
                let path = "/\(id)" + "/account_states"
                let queryItem = URLQueryItem(name: "session_id", value: sessionID)
                return (path, [queryItem])
                
            case .rate(id: let id, sessionID: let sessionID):
                let path = "/\(id)" + "/rating"
                let queryItem = URLQueryItem(name: "session_id", value: sessionID)
                return (path, [queryItem])
            }
        }
        
        
        public var url: URL {
            return Endpoint.getURL(for: "/tv" + components.path, query: components.query)
        }
    }
    
    
    // MARK: - Search
    enum Search {
        case movie(title: String, page: Int)
        case tv(name: String, page: Int)
        
        private var components: (path: String, query: [URLQueryItem]) {
            switch self {
            case .movie(let title, let page):
                let path = "/movie"
                let titleQuery = URLQueryItem(name: "query", value: title)
                let pageQuery = URLQueryItem(name: "page", value: String(page))
                return (path, [titleQuery, pageQuery])
                
            case .tv(let name, let page):
                let path = "/tv"
                let titleQuery = URLQueryItem(name: "query", value: name)
                let pageQuery = URLQueryItem(name: "page", value: String(page))
                return (path, [titleQuery, pageQuery])
            }
        }
        
        public var url: URL {
            return Endpoint.getURL(for: "/search" + components.path, query: components.query)
        }
    }
}
