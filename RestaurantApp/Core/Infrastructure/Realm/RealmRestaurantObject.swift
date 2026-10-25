//
//  RealmRestaurantObject.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

import Foundation
import RealmSwift

final class RealmRestaurantObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String = ""
    @Persisted var restaurantDescription: String = ""
    @Persisted var pictureURL: String = ""
    @Persisted var city: String = ""
    @Persisted var rating: String = ""
    
    convenience init(from model: RestaurantModel) {
        self.init()
        self.id = model.id
        self.name = model.name
        self.restaurantDescription = model.description
        self.pictureURL = model.pictureURL.absoluteString
        self.city = model.city
        self.rating = model.rating
    }
    
    func toModel() -> RestaurantModel {
        .init(
            id: id,
            name: name,
            description: restaurantDescription,
            pictureURL: URL(string: pictureURL) ?? URL(string: "about:blank")!,
            city: city,
            rating: rating
        )
    }
}
