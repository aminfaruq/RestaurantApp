//
//  RestaurantDetailModel.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import Foundation

// MARK: - Restaurant
public struct RestaurantDetailModel: Equatable {
    public let id, name, description, city: String
    public let address: String
    public let pictureURL: URL
    public let categories: [CategoryModel]
    public let menus: MenusModel
    public let rating: String
    public let customerReviews: [CustomerReviewModel]
    
    public init(id: String, name: String, description: String, city: String, address: String, pictureURL: URL, categories: [CategoryModel], menus: MenusModel, rating: String, customerReviews: [CustomerReviewModel]) {
        self.id = id
        self.name = name
        self.description = description
        self.city = city
        self.address = address
        self.pictureURL = pictureURL
        self.categories = categories
        self.menus = menus
        self.rating = rating
        self.customerReviews = customerReviews
    }
}

// MARK: - Category
public struct CategoryModel: Equatable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

// MARK: - CustomerReview
public struct CustomerReviewModel: Equatable {
    public let name, review, date: String
    
    public init(name: String, review: String, date: String) {
        self.name = name
        self.review = review
        self.date = date
    }
}

// MARK: - Menus
public struct MenusModel: Equatable {
    public let foods, drinks: [CategoryModel]
    
    public init(foods: [CategoryModel], drinks: [CategoryModel]) {
        self.foods = foods
        self.drinks = drinks
    }
}

extension RestaurantDetailModel {
    public func toRestaurantModel() -> RestaurantModel {
        .init(
            id: id,
            name: name,
            description: description,
            pictureURL: pictureURL,
            city: city,
            rating: rating
        )
    }
}
