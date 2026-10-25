//
//  FavoriteStore.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

public protocol FavoriteRestaurantStore {
    func retrieve() async throws -> [RestaurantModel]
    func insert(_ restaurant: RestaurantModel) async throws
    func delete(id: String) async throws
    func isFavorite(id: String) async throws -> Bool
}
