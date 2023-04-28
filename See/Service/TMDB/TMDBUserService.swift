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
    
    
    func markAsFavorites(_ mark: Bool, type: ShowType, id: Int, forUserSessionID sessionID: String, accountID: Int) async throws {
        do {
            let url = Endpoint.Account.markAsFavorite(accountID: accountID, sessionID: sessionID).url
            let parameters = Mark(favorite: mark, watchlist: nil, type: type.rawValue, id: id)
            
            // Create URL Request
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(parameters)
            
            let status = try await URLSession.shared.prefromTask(with: request, type: TMDBStatusResponse.self)
            
            if !status.success {
                throw status
            }
            
        } catch {
            throw error
        }
    }
    
    
    func markAsWatchlist(_ mark: Bool, type: ShowType, id: Int, forUserSessionID sessionID: String, accountID: Int) async throws {
        do {
            let url = Endpoint.Account.markAsWatchlist(accountID: accountID, sessionID: sessionID).url
            let parameters = Mark(favorite: nil, watchlist: mark, type: type.rawValue, id: id)
            
            // Create URL Request
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(parameters)
            
            let status = try await URLSession.shared.prefromTask(with: request, type: TMDBStatusResponse.self)
            
            if !status.success {
                throw status
            }
            
        } catch {
            throw error
        }
    }
    
    
    
    func getFavorite(_ type: ShowType, forUserSessionID sessionID: String, accountID: Int) async throws -> [Show] {
        do {
            let typeString = (type == .movie) ? "movies" : "tv"
            let url = Endpoint.Account.getFavorites(accountID: accountID, type: typeString, sessionID: sessionID).url
            let favorites = try await URLSession.shared.prefromTask(with: url, type: ShowResponse.self)
            return favorites.results
            
        } catch {
            throw error
        }
    }
    
    
    func getWatchlist(_ type: ShowType, forUserSessionID sessionID: String, accountID: Int) async throws -> [Show] {
        do {
            let typeString = (type == .movie) ? "movies" : "tv"
            let url = Endpoint.Account.getWatchlist(accountID: accountID, type: typeString, sessionID: sessionID).url
            let watchlist = try await URLSession.shared.prefromTask(with: url, type: ShowResponse.self)
            return watchlist.results
            
        } catch {
            throw error
        }
    }
}
