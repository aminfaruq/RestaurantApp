//
//  RealmFavoriteRestaurantStore.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

import Foundation
import RealmSwift

public final class RealmFavoriteRestaurantStore: FavoriteRestaurantStore {

    private let configuration: Realm.Configuration
    
    public init(configuration: Realm.Configuration = .defaultConfiguration) {
        self.configuration = configuration
    }
    
    private func getRealm() throws -> Realm {
        try Realm(configuration: configuration)
    }
    
    public func retrieve() async throws -> [RestaurantModel] {
        let realm = try getRealm()
        let objects = realm.objects(RealmRestaurantObject.self)
        return objects.map { $0.toModel() }
    }
    
    public func insert(_ restaurant: RestaurantModel) async throws {
        let realm = try getRealm()
        let object = RealmRestaurantObject(from: restaurant)
        
        try realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    public func delete(id: String) async throws {
        let realm = try getRealm()
        if let object = realm.object(ofType: RealmRestaurantObject.self, forPrimaryKey: id) {
            try realm.write {
                realm.delete(object)
            }
        }
    }
    
    public func isFavorite(id: String) async throws -> Bool {
        let realm = try getRealm()
        return realm.object(ofType: RealmRestaurantObject.self, forPrimaryKey: id) != nil
    }
}
