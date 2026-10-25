//
//  RestaurantDetailLoader.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

public protocol RestaurantDetailLoader {
    func loadRestaurantDetail(id: String) async throws -> RestaurantDetailModel
    func addReview(review: AddReviewBody) async throws
}
