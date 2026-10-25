//
//  LocalRestaurantListLoader.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

import Foundation

public protocol FavoriteRestaurantManager {
    func save(_ restaurant: RestaurantModel) async throws
    func remove(id: String) async throws
    func isFavorite(id: String) async throws -> Bool
}

public final class LocalRestaurantListLoader: RestaurantListLoader, FavoriteRestaurantManager {
   
    private let store: FavoriteRestaurantStore
    
    public init (store: FavoriteRestaurantStore) {
        self.store = store
    }
    
    public func loadRestaurant(query: String = "") async throws -> [RestaurantModel] {
        let restaurants = try await store.retrieve()
        
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            return restaurants
        } else {
            return restaurants.filter {
                $0.name.localizedCaseInsensitiveContains(trimmedQuery) || $0.city.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }
    }
    
    public func save(_ restaurant: RestaurantModel) async throws {
        try await store.insert(restaurant)
    }
    
    public func remove(id: String) async throws {
        try await store.delete(id: id)
    }
    
    public func isFavorite(id: String) async throws -> Bool {
        try await store.isFavorite(id: id)
    }
}
