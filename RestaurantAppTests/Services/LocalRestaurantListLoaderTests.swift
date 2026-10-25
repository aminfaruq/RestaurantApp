//
//  LocalRestaurantListLoaderTests.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

import XCTest
import RestaurantApp

final class LocalRestaurantListLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.messages, [])
    }
    
    func test_loadRestaurant_requestsRetrieveFromStore() async {
        let (sut, spy) = makeSUT()
        
        _ = try? await sut.loadRestaurant()
        
        XCTAssertEqual(spy.messages, [.retrieve])
    }
    
    func test_loadRestaurant_failsOnStoreError() async {
        let (sut, spy) = makeSUT()
        let expectedError = anyError()
        spy.stub(with: .failure(expectedError))
        
        do {
            _ = try await sut.loadRestaurant()
            XCTFail("Expected error \(expectedError), got success instead")
        } catch let error as NSError {
            XCTAssertEqual(error.code, expectedError.code)
            XCTAssertEqual(error.domain, expectedError.domain)
        }
    }
    
    func test_loadRestaurant_deliversEmptyOnEmptyStore() async throws {
        let (sut, spy) = makeSUT()
        spy.stub(with: .success([]))
        
        let result = try await sut.loadRestaurant()
        
        XCTAssertEqual(result, [])
    }
    
    func test_loadRestaurant_deliversAllItemsOnEmptyQuery() async throws {
        let (sut, spy) = makeSUT()
        let items = [makeRestaurant(name: "A"), makeRestaurant(name: "B")]
        spy.stub(with: .success(items))
        
        let result = try await sut.loadRestaurant(query: "")
        
        XCTAssertEqual(result, items)
    }
    
    func test_loadRestaurant_filtersMatchingQueryByNameOrCity() async throws {
        let (sut, spy) = makeSUT()
        let rest1 = makeRestaurant(name: "Padang Merdeka", city: "Jakarta")
        let rest2 = makeRestaurant(name: "Sate Khas Senayan", city: "Bandung")
        spy.stub(with: .success([rest1, rest2]))
        
        let searchResultByName = try await sut.loadRestaurant(query: "padang")
        XCTAssertEqual(searchResultByName, [rest1])
        
        let searchResultByCity = try await sut.loadRestaurant(query: "bandung")
        XCTAssertEqual(searchResultByCity, [rest2])
        
        let noMatchResult = try await sut.loadRestaurant(query: "Surabaya")
        XCTAssertEqual(noMatchResult, [])
    }
    
    func test_save_requestsInsertToStore() async throws {
        let (sut, spy) = makeSUT()
        let restaurant = makeRestaurant(name: "Test")
        
        try await sut.save(restaurant)
        
        XCTAssertEqual(spy.messages, [.insert(restaurant)])
    }
    
    func test_remove_requestDeleteToStore() async throws {
        let (sut, spy) = makeSUT()
        let id = "rest-123"

        try await sut.remove(id: id)
        
        XCTAssertEqual(spy.messages, [.delete(id: id)])
    }
    
    //MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalRestaurantListLoader, spy: FavoriteRestaurantStoreSpy) {
        let spy = FavoriteRestaurantStoreSpy()
        let sut = LocalRestaurantListLoader(store: spy)
        
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeRestaurant(name: String, city: String = "any-city") -> RestaurantModel {
        .init(
            id: UUID().uuidString,
            name: name,
            description: "a desc",
            pictureURL: anyURL(),
            city: city,
            rating: "4.5"
        )
    }
    
    private class FavoriteRestaurantStoreSpy: FavoriteRestaurantStore {
        
        enum Message: Equatable {
            case retrieve
            case insert(_ restaurant: RestaurantModel)
            case delete(id: String)
            case isFavorite(id: String)
        }
        
        private(set) var messages = [Message]()
        private var retrieveStub: Result<[RestaurantModel], Error>?
        
        func stub(with result: Result<[RestaurantModel], Error>) {
            self.retrieveStub = result
        }
        
        func retrieve() async throws -> [RestaurantModel] {
            messages.append(.retrieve)
            return try retrieveStub?.get() ?? []
        }
        
        func insert(_ restaurant: RestaurantModel) async throws {
            messages.append(.insert(restaurant))
        }
        
        func delete(id: String) async throws {
            messages.append(.delete(id: id))
        }
        
        func isFavorite(id: String) async throws -> Bool {
            messages.append(.isFavorite(id: id))
            return false
        }
    }
}
