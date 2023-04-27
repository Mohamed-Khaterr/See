//
//  TMDBUserService.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import Foundation


final class TMDBUserService {
    
    func getUserToken() async throws -> String {
        let url = Endpoint.Auth.requestToken.url
        do {
            let result = try await URLSession.shared.prefromTask(with: url, type: TokenResponse.self)
            return result.token
            
        } catch {
            throw error
        }
    }
    
    
    
    func getUserSessionID(token: String) async throws -> String {
        let url = Endpoint.Auth.requestSessionID.url
        let parameters = SessionIDRequest(requestToken: token)
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(parameters)
        
        do {
            let result = try await URLSession.shared.prefromTask(with: request, type: SessionIDResponse.self)
            return result.sessionId
            
        } catch {
            throw error
        }
    }
    
    
    
    func login(withUserToken token: String, username: String, password: String) async throws -> String {
        let url = Endpoint.Auth.login.url
        let parameters = LoginRequest(username: username, password: password, requestToken: token)
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(parameters)
        
        do {
            let result = try await URLSession.shared.prefromTask(with: request, type: TokenResponse.self)
            let newToken = result.token
            return newToken
        } catch {
            throw error
        }
    }
    
    
    
    func getAccountInfo(withUserSessionID sessionID: String) async throws -> Account {
        let url = Endpoint.Account.info(sessionID: sessionID).url
        
        do {
            let accountInfo = try await URLSession.shared.prefromTask(with: url, type: Account.self)
            return accountInfo
        } catch {
            throw error
        }
    }
    
    
    
    func logout(withUserSessionID sessionID: String) async throws -> Bool {
        let url = Endpoint.Auth.logout.url
        let parameters = LogoutRequest(sessionId: sessionID)
        
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = try! JSONEncoder().encode(parameters)
        
        do {
            let result = try await URLSession.shared.prefromTask(with: request, type: LogoutResponse.self)
            return result.success
        } catch {
            throw error
        }
    }
    
    
    func getStatus(_ type: ShowType, id: Int) async throws -> Status {
        let sessionID = User.shared.getSessionID() ?? ""
        
        let url: URL!
        switch type {
        case .movie:
            url = Endpoint.Movie.getStatus(id: id, sessionID: sessionID).url
        case .tv:
            url = Endpoint.TV.getStatus(id: id, sessionID: sessionID).url
        }
        
        do {
            let result = try await URLSession.shared.prefromTask(with: url, type: Status.self)
            return result
            
        } catch {
            throw error
        }
    }
    
    
    func markAsFavorites(_ mark: Bool, type: ShowType, id: Int) async throws -> String {
        let sessionID = User.shared.getSessionID() ?? ""
        
        do {
            let account = try await getAccountInfo(withUserSessionID: sessionID)
            let url = Endpoint.Account.markAsFavorite(accountID: account.id, sessionID: sessionID).url
            let parameters = Mark(favorite: mark, watchlist: nil, type: type.rawValue, id: id)
            
            // Create URL Request
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(parameters)
            
            let result = try await URLSession.shared.prefromTask(with: request, type: TMDBStatusResponse.self)
            
            if result.success {
                return result.statusMessage
            } else {
                throw result
            }
            
        } catch {
            throw error
        }
    }
    
    
    func markAsWatchlist(_ mark: Bool, type: ShowType, id: Int) async throws -> String {
        let sessionID = User.shared.getSessionID() ?? ""
        
        do {
            let account = try await getAccountInfo(withUserSessionID: sessionID)
            let url = Endpoint.Account.markAsWatchlist(accountID: account.id, sessionID: sessionID).url
            let parameters = Mark(favorite: nil, watchlist: mark, type: type.rawValue, id: id)
            
            // Create URL Request
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(parameters)
            
            let result = try await URLSession.shared.prefromTask(with: request, type: TMDBStatusResponse.self)
            
            if result.success {
                return result.statusMessage
                
            } else {
                throw result
            }
            
        } catch {
            print(error)
            throw error
        }
    }
    
    
    
    func getFavorite(_ type: ShowType, sessionID: String, accountID: Int) async throws -> [Show] {
        do {
            let typeString = (type == .movie) ? "movies" : "tv"
            let url = Endpoint.Account.getFavorites(accountID: accountID, type: typeString, sessionID: sessionID).url
            let favorites = try await URLSession.shared.prefromTask(with: url, type: ShowResponse.self)
            return favorites.results
            
        } catch {
            throw error
        }
    }
    
    
    func getWatchlist(_ type: ShowType, sessionID: String, accountID: Int) async throws -> [Show] {
        do {
            let typeString = (type == .movie) ? "movies" : "tv"
            let url = Endpoint.Account.getWatchlist(accountID: accountID, type: typeString, sessionID: sessionID).url
            let watchlist = try await URLSession.shared.prefromTask(with: url, type: ShowResponse.self)
            return watchlist.results
            
        } catch {
            throw error
        }
    }
    
    
    func rate(_ type: ShowType, id: Int, isRating: Bool) async throws -> TMDBStatusResponse {
        let sessionID = User.shared.getSessionID() ?? ""
        
        let url: URL!
        switch type {
        case .movie:
            url = Endpoint.Movie.rate(id: id, sessionID: sessionID).url
        case .tv:
            url = Endpoint.TV.rate(id: id, sessionID: sessionID).url
        }
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if isRating {
            request.httpMethod = "POST"
            request.httpBody = try! JSONSerialization.data(withJSONObject: ["value": 5], options: .fragmentsAllowed)
            
        } else {
            request.httpMethod = "DELETE"
        }
        
        do {
            let result = try await URLSession.shared.prefromTask(with: request, type: TMDBStatusResponse.self)
            
            if result.success {
                return result
            } else {
                throw result
            }
            
        } catch {
            throw error
        }
    }
}
