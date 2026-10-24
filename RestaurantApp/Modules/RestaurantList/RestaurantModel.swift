//
//  RestaurantModel.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import Foundation

public struct RestaurantModel: Equatable {
    public let id: String
    public let name: String
    public let description: String
    public let pictureURL: URL
    public let city: String
    public let rating: String
    
    public init(id: String, name: String, description: String, pictureURL: URL, city: String, rating: String) {
        self.id = id
        self.name = name
        self.description = description
        self.pictureURL = pictureURL
        self.city = city
        self.rating = rating
    }
}
