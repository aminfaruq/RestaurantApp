//
//  RemoteRestaurantListLoaderTests.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import XCTest
import RestaurantApp

@MainActor
final class RemoteRestaurantListLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestURL() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.requestedURLs, [])
    }
    
    func test_loadRestaurant_requestedURL() async {
        let url = anyURL()
        let (sut, spy) = makeSUT(url: url)
        
        let expectedURL = URL(string: url.absoluteString + "/search?q=melting")
        
        _ = try? await sut.loadRestaurant(query: "melting")
        
        XCTAssertEqual(spy.requestedURLs, [expectedURL])
    }
    
    func test_loadRestaurant_deliversConnectivityError() async {
        let (sut, spy) = makeSUT()
        spy.stub(withError: anyError())
        
        await assertThat({
            _ = try await sut.loadRestaurant()
        }, throws: .connectivity)
    }
    
    func test_loadRestaurant_deliversErrorInvalidDataOnNon200StatusCode() async {
        let samples = [199, 300, 400, 404, 500]
        
        for code in samples {
            let (sut, spy) = makeSUT()
            spy.stub(withStatusCode: code, data: Data())
            
            await assertThat({
                _ = try await sut.loadRestaurant()
            }, throws: .invalidData)
        }
    }
    
    func test_loadRestaurant_deliversDecodeErrorOn200StatusCode() async {
        let (sut, spy) = makeSUT()
        let json = "Invalid JSON".data(using: .utf8)!
        spy.stub(withStatusCode: 200, data: json)
        
        await assertThat({
            _ = try await sut.loadRestaurant()
        }, throws: .decodeError)
    }
    
    func test_loadRestaurant_deliversEmptyJSONOn200StatusCode() async throws {
        let (sut, spy) = makeSUT()
        let restaurant = makeRestaurants([])
        spy.stub(withStatusCode: 200, data: restaurant)
        
        let receivedResult = try await sut.loadRestaurant()
        XCTAssertEqual(receivedResult, [])
    }
    
    func test_loadRestaurant_deliversResturantOn200StatusCode() async throws {
        let (sut, spy) = makeSUT()
        let restaurant = makeRestaurant()
        let json = makeRestaurants([restaurant.json])
        
        spy.stub(withStatusCode: 200, data: json)
        
        let receivedResult = try await sut.loadRestaurant()
        XCTAssertEqual(receivedResult, [restaurant.model])
    }
    
    //MARK: Helpers
    private func makeSUT(
        url: URL = anyURL(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteRestaurantListLoader, spy: HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteRestaurantListLoader(url: url, client: spy)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, spy)
    }
    
    private func makeRestaurants(_ restaurants: [[String: Any]]) -> Data {
        let json: [String: Any] = [
            "restaurants": restaurants
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeRestaurant(
        id: String = "rytihg45834q9t",
        name: String = "a name",
        description: String = "a descriptionion",
        pictureId: String = "a picture",
        city: String = "a city",
        rating: Double = 0
    ) -> (model: RestaurantModel, json: [String: Any]) {
        let json: [String: Any] = [
            "id" : id,
            "name": name,
            "description": description,
            "pictureId": pictureId,
            "city": city,
            "rating": rating,
        ]
        
        let model = RestaurantModel(
            id: id,
            name: name,
            description: description,
            pictureURL: URL(string: "https://restaurant-api.dicoding.dev/images/medium/\(pictureId)")!,
            city: city,
            rating: "\(rating)"
        )
        
        return (model, json)
    }
    
   
}
