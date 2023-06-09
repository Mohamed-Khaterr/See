//
//  URLSession+Extension.swift
//  See
//
//  Created by Khater on 3/15/23.
//

import Foundation


extension URLSession {
    
    // With URL
    public func prefromTask<ResponseType: Decodable>(with url: URL, type: ResponseType.Type) async throws -> ResponseType {
        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                self?.dataTaskHandler(data: data, response: response, error: error, type: type, continuation: continuation)
            }
            .resume()
        })
    }
    
    
    // With URL Request
    public func prefromTask<ResponseType: Decodable>(with request: URLRequest, type: ResponseType.Type) async throws -> ResponseType {
        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                self?.dataTaskHandler(data: data, response: response, error: error, type: type, continuation: continuation)
            }
            .resume()
        })
    }
    
    
    private func dataTaskHandler<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, type: T.Type, continuation: CheckedContinuation<T, Error>) {
        if let error = error {
            continuation.resume(throwing: error)
            return
        }
        
        guard let data = data else {
            continuation.resume(throwing: CustomError.noData)
            return
        }
        
        // Parse Response JSON Data
        if let result = parseJSON(type: type, data: data) {
            continuation.resume(returning: result)
            return

        } else {
            // Fail to parse response
            // Check if JSON is TMDB Status Response
            if let tmdbStatus = self.parseJSON(type: TMDBStatusResponse.self, data: data) {
                continuation.resume(throwing: tmdbStatus)
                return
            }
            
            // Fail to parse response
            // Check if JSON Data is TMDB Error
            if let tmdbError = self.parseJSON(type: TMDBErrorResponse.self, data: data) {
                continuation.resume(throwing: tmdbError)
                return
            }else {
                continuation.resume(throwing: CustomError.decodingError)
            }
        }
    }
    
    public func getOnlyData(with url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: CustomError.noData)
                    return
                }
                
                continuation.resume(returning: data)
            }
            .resume()
        })
    }
    
    
    
    // MARK: - Helper Functions
    
    private func parseJSON<T: Decodable>(type: T.Type, data: Data) -> T? {
        do {
            let decodedData = try JSONDecoder().decode(type, from: data)
            return decodedData
            
        } catch {
            let className = String(describing: T.self)
            print("[ERROR]: JSON Decoder error [parseJSON]: error occured while JSON Decoding \(className)" )
            print("[Error Message]: \(error)\n")
            let responseData = String(data: data, encoding: .utf8) ?? "nil"
            print("[Response Data String]: \(responseData)")
            return nil
        }
    }
}
