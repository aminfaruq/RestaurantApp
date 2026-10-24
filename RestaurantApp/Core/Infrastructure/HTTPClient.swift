//
//  HTTPClient.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import Foundation

public struct HTTPBody: Equatable {
    public enum ContentType: Equatable {
        case json
    }
    
    public let data: Data
    public let contentType: ContentType
    
    public init(data: Data, contentType: ContentType) {
        self.data = data
        self.contentType = contentType
    }
}

public protocol HTTPClient {
    typealias Result = (Data, HTTPURLResponse)
    
    func get(from url: URL) async throws -> Result
    
    func post(from url: URL, headers: [String: String]?, body: HTTPBody?) async throws -> Result
}
