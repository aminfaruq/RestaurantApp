//
//  RealmFavoriteRestaurantStoreTests.swift
//  RestaurantAppTests
//
//  Created by Amin faruq on 26/10/26.
//

import XCTest
import RealmSwift
import RestaurantApp

final class RealmFavoriteRestaurantStoreTests: XCTestCase {
    
    private var inMemoryRealm: Realm?
    
    override func tearDown() {
        inMemoryRealm = nil
        super.tearDown()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() async throws {
        let sut = makeSUT()
        
        let result = try await sut.retrieve()
        
        XCTAssertEqual(result, [])
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() async throws {
        let sut = makeSUT()
        
        let firstResult = try await sut.retrieve()
        let secondResult = try await sut.retrieve()
        
        XCTAssertEqual(firstResult, [])
        XCTAssertEqual(secondResult, [])
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() async throws {
        let sut = makeSUT()
        let restaurant = makeRestaurant(id: "1", name: "Melting Pot")
        
        try await sut.insert(restaurant)
        let result = try await sut.retrieve()
        
        XCTAssertEqual(result, [restaurant])
    }
    
    func test_insert_overridesPreviouslyInsertedValueWithSameID() async throws {
        let sut = makeSUT()
        let originalRestaurant = makeRestaurant(id: "1", name: "Old name")
        let updateRestaurant = makeRestaurant(id: "1", name: "New name")
        
        try await sut.insert(originalRestaurant)
        try await sut.insert(updateRestaurant)
        
        let result = try await sut.retrieve()
        
        XCTAssertEqual(result, [updateRestaurant])
        XCTAssertEqual(result.count, 1)
    }
    
    func test_delete_emptiesPreviouslyInsertedValue() async throws {
        let sut = makeSUT()
        let restaurant = makeRestaurant(id: "1", name: "Melting Pot")
        
        try await sut.insert(restaurant)
        try await sut.delete(id: restaurant.id)
        
        let result = try await sut.retrieve()
        
        XCTAssertEqual(result, [])
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() async throws {
        let sut = makeSUT()
        
        try await sut.delete(id: "non-existent-id")
        
        let result = try await sut.retrieve()
        XCTAssertEqual(result, [])
    }
    
    func test_isFavorite_deliversFalseOnEmptyCache() async throws {
        let sut = makeSUT()
        
        let isFav = try await sut.isFavorite(id: "any-id")
        
        XCTAssertFalse(isFav)
    }
    
    func test_isFavorite_deliversTrueWhenItemExists() async throws {
        let sut = makeSUT()
        let restaurant = makeRestaurant(id: "fav-123")
        
        try await sut.insert(restaurant)
        let isFav = try await sut.isFavorite(id: "fav-123")
        
        XCTAssertTrue(isFav)
    }
    
    //MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> RealmFavoriteRestaurantStore {
        var configuration = Realm.Configuration()
        
        configuration.inMemoryIdentifier = UUID().uuidString
        
        inMemoryRealm = try! Realm(configuration: configuration)
        
        let sut = RealmFavoriteRestaurantStore(configuration: configuration)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func makeRestaurant(id: String, name: String = "any name") -> RestaurantModel {
        .init(
            id: id,
            name: name,
            description: "any description",
            pictureURL: anyURL(),
            city: "any city",
            rating: "4.5"
        )
    }
}
