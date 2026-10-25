//
//  RemoteRestaurantDetailLoaderTests.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import RestaurantApp
import XCTest

@MainActor
final class RemoteRestaurantDetailLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestFromURL() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.requestedURLs, [])
    }
    
    func test_loadRestaurantDetail_requestedURL() async {
        let url = anyURL()
        let (sut, spy) = makeSUT(url: url)
        let expectedURL = URL(string: url.absoluteString + "/detail/rqdv5juczeskfw1e867")
        
        _ = try? await sut.loadRestaurantDetail(id: "rqdv5juczeskfw1e867")
        
        XCTAssertEqual(spy.requestedURLs, [expectedURL])
    }
    
    func test_loadRestaurantDetail_deliversConnectivityError() async {
        let (sut, spy) = makeSUT()
        spy.stub(withError: anyError())
        
        await assertThat({
            _ = try await sut.loadRestaurantDetail(id: "")
        }, throws: .connectivity)
    }
    
    func test_loadRestaurantDetail_deliversErrorInvalidDataOnNon200StatusCode() async {
        let samples = [199, 300, 400, 404, 500]
        
        for code in samples {
            let (sut, spy) = makeSUT()
            spy.stub(withStatusCode: code, data: Data())
            
            await assertThat({
                _ = try await sut.loadRestaurantDetail(id: "")
            }, throws: .invalidData)
        }
    }
    
    func test_loadRestaurantDetail_deliversDecodeErrorOn200StatusCode() async {
        let (sut, spy) = makeSUT()
        let json = "Invalid JSON".data(using: .utf8)!
        spy.stub(withStatusCode: 200, data: json)
        
        await assertThat({
            _ = try await sut.loadRestaurantDetail(id: "")
        }, throws: .decodeError)
    }
    
    func test_loadRestaurantDetail_deliversResultOn200StatusCode() async throws {
        let (sut, spy) = makeSUT()
        let id = "rqdv5juczeskfw1e867"
        let result = makeResult(id: id)
        let json = makeRestaurant(result.json)
        spy.stub(withStatusCode: 200, data: json)
        
        let receivedResult = try await sut.loadRestaurantDetail(id: id)
        XCTAssertEqual(receivedResult, result.model)
    }
    
    //MARK: Add Review
    func test_addReview_requestedURL() async {
        let url = anyURL()
        let (sut, spy) = makeSUT(url: url)
        let review = makeReview()
        let expectedURL = URL(string: url.absoluteString + "/review")!
        let expectedBody = makeBody(id: review.id, name: review.name, review: review.review)
        
        _ = try? await sut.addReview(review: review)
        
        XCTAssertEqual(spy.requestedURLs, [expectedURL])
        XCTAssertEqual(spy.messages, [
            .post(expectedURL, headers: nil, body: expectedBody)
        ])
    }
    
    func test_addReview_deliversConnectivityError() async {
        let (sut, spy) = makeSUT()
        spy.stub(withError: anyError())
        
        await assertThat({
            _ = try await sut.addReview(review: makeReview())
        }, throws: .connectivity)
    }
    
    func test_addReview_deliversErrorInvalidDataOnNon200StatusCode() async {
        let samples = [199, 300, 400, 404, 500]
        
        for code in samples {
            let (sut, spy) = makeSUT()
            spy.stub(withStatusCode: code, data: Data())
            
            await assertThat({
                _ = try await sut.addReview(review: makeReview())
            }, throws: .invalidData)
        }
    }
    
    func test_addReview_deliversSuccessOn200StatusCode() async {
        let (sut, spy) = makeSUT()
        spy.stub(withStatusCode: 200, data: Data())
        
        do {
            try await sut.addReview(review: makeReview())
        } catch {
            XCTFail("Expected success, got \(error) instead")
        }
    }
    
    //MARK: Helpers
    private func makeSUT(
        url: URL = anyURL(),
        file: StaticString = #filePath,
        line: UInt = #line,
    ) -> (sut: RemoteRestaurantDetailLoader, spy: HTTPClientSpy){
        let spy = HTTPClientSpy()
        let sut = RemoteRestaurantDetailLoader(url: url, client: spy)
        
        return (sut, spy)
    }
    
    private func makeReview() -> AddReviewBody {
        .init(id: "trurtgjx", name: "a name", review: "a review")
    }
    
    private func makeBody(id: String, name: String, review: String) -> HTTPBody {
        let json: [String: Any] = [
            "id": id,
            "name": name,
            "review": review
        ]
        
        let data = try! JSONSerialization.data(withJSONObject: json, options: .sortedKeys)
        return HTTPBody(data: data, contentType: .json)
    }
    
    private func makeRestaurant(_ restaurant: [String: Any]) -> Data {
        let json: [String: Any] = [
            "restaurant": restaurant
        ]
        
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeResult(
        id: String,
        input: String = "a string",
        rating: Double = 0,
    ) -> (model: RestaurantDetailModel, json: [String: Any]) {
        let model = RestaurantDetailModel(
            id: id,
            name: input,
            description: input,
            city: input,
            address: input,
            pictureURL: URL(string: "https://restaurant-api.dicoding.dev/images/medium/\(input)")!,
            categories: [
                CategoryModel(name: input)
            ],
            menus: MenusModel(
                foods: [
                    CategoryModel(name: input)
                ],
                drinks: [
                    CategoryModel(name: input)
                ]),
            rating: "\(rating)",
            customerReviews: [
                CustomerReviewModel(name: input, review: input, date: input)
            ]
        )
        
        let json: [String: Any] = [
            "id": id,
            "name": input,
            "description": input,
            "city": input,
            "address": input,
            "pictureId": input,
            "categories": [makeNames(input: input)],
            "menus": makeMenus(input: [makeNames(input: input)]),
            "rating": rating,
            "customerReviews": [makeCustomerReviews(input: input)]
        ]
        return (model, json)
    }
    
    private func makeCustomerReviews(input: String) -> [String: Any] {
        let json: [String: Any] = [
            "name": input,
            "review": input,
            "date": input
        ]
        return json
    }
    
    private func makeNames(input: String) -> [String: Any] {
        let json: [String: Any] = [
            "name": input,
        ]
        return json
    }
    
    private func makeMenus(input: [[String: Any]]) -> [String: Any] {
        let json: [String: Any] = [
            "foods": input,
            "drinks": input,
        ]
        return json
    }
}
