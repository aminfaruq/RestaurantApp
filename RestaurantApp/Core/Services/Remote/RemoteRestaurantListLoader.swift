//
//  RemoteRestaurantListLoader.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import Foundation

public final class RemoteRestaurantListLoader: RestaurantListLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func loadRestaurant(query: String = "") async throws -> [RestaurantModel] {
        let requestedURL = url
            .appending(path: "search")
            .appending(queryItems: [
                URLQueryItem(name: "q", value: query)
            ])
        
        let response: HTTPURLResponse
        let data: Data
        
        do {
            (data, response) = try await client.get(from: requestedURL)

        } catch {
            throw NetworkError.connectivity
        }
        
        switch response.statusCode {
            case 200:
                guard let root = try? JSONDecoder().decode(RootDTO.self, from: data) else {
                    throw NetworkError.decodeError
                }
                return root.restaurants.map({ $0.toModel() })
            default:
                throw NetworkError.invalidData
        }
    }
    
    private struct RootDTO: Decodable {
        let restaurants: [RemoteRestaurantDTO]
    }
    
    private struct RemoteRestaurantDTO: Decodable {
        private let id: String
        private let name: String
        private let description: String
        private let pictureId: String
        private let city: String
        private let rating: Double
        
        private static let imageBaseURL = URL(string: "https://restaurant-api.dicoding.dev/images/medium/")
        
        func toModel() -> RestaurantModel {
            .init(
                id: id,
                name: name,
                description: description,
                pictureURL: makeImageURL(from: pictureId),
                city: city,
                rating: "\(rating)")
        }
        
        private func makeImageURL(from picture: String) -> URL {
            if let baseURL = RemoteRestaurantDTO.imageBaseURL {
                return baseURL.appending(path: pictureId)
            }
            
            return URL(string: "about:blank") ?? URL(fileURLWithPath: "")
        }
    }
}
