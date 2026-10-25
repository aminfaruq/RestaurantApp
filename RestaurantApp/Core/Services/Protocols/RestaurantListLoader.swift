//
//  RestaurantListLoader.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

public protocol RestaurantListLoader {
    func loadRestaurant(query: String) async throws -> [RestaurantModel]
}
