//
//  URLSessionHTTPClient.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL) async throws -> HTTPClient.Result {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnexpectedValueRepresentation()
        }
        
        return (data, httpResponse)
    }
    
    public func post(from url: URL, headers: [String : String]?, body: HTTPBody?) async throws -> HTTPClient.Result {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        if let body {
            request.httpBody = body.data
            
            switch body.contentType {
                case .json:
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnexpectedValueRepresentation()
        }
        
        return (data, httpResponse)
    }
    
    private struct UnexpectedValueRepresentation: Error {}
}
