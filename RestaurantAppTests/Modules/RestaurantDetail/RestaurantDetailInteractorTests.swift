//
//  RestaurantDetailInteractorTests.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import RxSwift
import XCTest
import RestaurantApp

@MainActor
final class RestaurantDetailInteractorTests: XCTestCase {
    
    private let disposeBag = DisposeBag()
    
    func test_init_doesNotRequestFromLoader() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.loadRestaurantDetailCallCount, 0)
        XCTAssertEqual(spy.addReviewCallCount, 0)
    }
    
    func test_fetchRestaurantDetail_deliversErrorOnFailure() async {
        let (sut, spy) = makeSUT()
        let expectedError = anyError()
        spy.loadRestaurantDetailStub(with: .failure(expectedError))
        
        var receivedError: NSError?
        let exp = expectation(description: "Wait from Single error")
        
        sut.fetchRestaurantDetail(id: "")
            .subscribe(
                onFailure: { error in
                    receivedError = error as NSError
                    exp.fulfill()
                }
            )
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError?.code, expectedError.code)
        XCTAssertEqual(receivedError?.domain, expectedError.domain)
        XCTAssertEqual(spy.loadRestaurantDetailCallCount, 1)
        
    }
    
    func test_fetchRestaurantDetail_deliversResultOnSuccess() async {
        let (sut, spy) = makeSUT()
        let expectedResult = makeResult(id: "any-id")
        spy.loadRestaurantDetailStub(with: .success(expectedResult))
        
        var receivedResult: RestaurantDetailModel?
        let exp = expectation(description: "Wait from Single success")
        
        sut.fetchRestaurantDetail(id: "any-id")
            .subscribe(
                onSuccess: { result in
                    receivedResult = result
                    exp.fulfill()
                }
            )
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedResult, expectedResult)
        XCTAssertEqual(spy.loadRestaurantDetailCallCount, 1)
    }
    
    func test_addReview_deliversErrorOnFailure() async {
        let (sut, spy) = makeSUT()
        let expectedError = anyError()
        spy.addReviewStub(with: .failure(expectedError))
        
        var receivedError: NSError?
        let exp = expectation(description: "Wait from Completable error")
        
        sut.addReview(body: AddReviewBody(id: "an-id", name: "a name", review: "a review"))
            .subscribe(
                onError: { error in
                    receivedError = error as NSError
                    exp.fulfill()
                }
            )
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError?.code, expectedError.code)
        XCTAssertEqual(receivedError?.domain, expectedError.domain)
        XCTAssertEqual(spy.addReviewCallCount, 1)
    }
    
    func test_addReview_deliversOnComplete() async {
        let (sut, spy) = makeSUT()
        spy.addReviewStub(with: .success(()))
        
        let exp = expectation(description: "Wait from Single error")
        
        sut.addReview(body: AddReviewBody(id: "an-id", name: "a name", review: "a review"))
            .subscribe(
                onCompleted: {
                    exp.fulfill()
                }
            )
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertEqual(spy.addReviewCallCount, 1)
    }
        
    func test_isFavorite_deliversErrorOnFailure() async {
        let (sut, spy) = makeSUT()
        let expectedError = anyError()
        spy.isFavoriteStub = .failure(expectedError)
        
        var receivedError: NSError?
        let exp = expectation(description: "Wait from Single error")
        
        sut.isFavorite(id: "any-id")
            .subscribe(
                onFailure: { error in
                    receivedError = error as NSError
                    exp.fulfill()
                }
            )
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError?.code, expectedError.code)
        XCTAssertEqual(receivedError?.domain, expectedError.domain)
        XCTAssertEqual(spy.isFavoriteCallCount, 1)
    }
    
    func test_isFavorite_deliversStatusOnSuccess() async {
        let (sut, spy) = makeSUT()
        spy.isFavoriteStub = .success(true)
        
        var receivedStatus: Bool?
        let exp = expectation(description: "Wait for isFavorite")
        
        sut.isFavorite(id: "any-id")
            .subscribe(
                onSuccess: { status in
                    receivedStatus = status
                    exp.fulfill()
                }
            )
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        XCTAssertEqual(receivedStatus, true)
        XCTAssertEqual(spy.isFavoriteCallCount, 1)
    }
    
    func test_toggleFavorite_savesWhenNotFavorite() async {
        let (sut, spy) = makeSUT()
        let restaurant = RestaurantModel(id: "1", name: "A", description: "B", pictureURL: anyURL(), city: "C", rating: "4")
        spy.isFavoriteStub = .success(false)
        
        var newStatus: Bool?
        let exp = expectation(description: "Wait for toggle")
        
        sut.toggleFavorite(restaurant: restaurant)
            .subscribe(onSuccess: { status in
                newStatus = status
                exp.fulfill()
            })
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertEqual(newStatus, true)
        XCTAssertEqual(spy.saveCallCount, 1)
        XCTAssertEqual(spy.removeCallCount, 0)
    }
    
    func test_toggleFavorite_removesWhenAllreadyFavorite() async {
        let (sut, spy) = makeSUT()
        let restaurant = RestaurantModel(id: "1", name: "A", description: "B", pictureURL: anyURL(), city: "C", rating: "4")
        spy.isFavoriteStub = .success(true)
        
        var newStatus: Bool?
        let exp = expectation(description: "Wait for toggle")
        
        sut.toggleFavorite(restaurant: restaurant)
            .subscribe(onSuccess: { status in
                newStatus = status
                exp.fulfill()
            })
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertEqual(newStatus, false)
        XCTAssertEqual(spy.removeCallCount, 1)
        XCTAssertEqual(spy.saveCallCount, 0)
    }
    
    //MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RestaurantDetailInteractor, spy: RestaurantDetailLoaderSpy) {
        let spy = RestaurantDetailLoaderSpy()
        let sut = RestaurantDetailInteractor(loader: spy, favoriteManager: spy)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        return (sut, spy)
    }
    
    private func makeResult(
        id: String,
        input: String = "a string",
        rating: Double = 0,
    ) -> RestaurantDetailModel {
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
        
       return model
    }
    
    private class RestaurantDetailLoaderSpy: RestaurantDetailLoader , FavoriteRestaurantManager {
      
        //MARK: - Load Restaurant
        private(set) var loadRestaurantDetailCallCount = 0
        private var loadRestaurantDetailStub: Result<RestaurantDetailModel, Error>?
        
        func loadRestaurantDetailStub(with result: Result<RestaurantDetailModel, Error>) {
            self.loadRestaurantDetailStub = result
        }

        func loadRestaurantDetail(id: String) async throws -> RestaurantDetailModel {
            loadRestaurantDetailCallCount += 1
            return try loadRestaurantDetailStub?.get() ?? .init(id: "", name: "", description: "", city: "", address: "", pictureURL: URL(string: "")!, categories: [], menus: MenusModel(foods: [], drinks: []), rating: "", customerReviews: [])
        }
        
        //MARK: - Add Review
        private(set) var addReviewCallCount = 0
        private var addReviewStub: Result<Void, Error>?
        
        func addReviewStub(with result: Result<Void, Error>) {
            self.addReviewStub = result
        }
        
        func addReview(review: AddReviewBody) async throws {
            addReviewCallCount += 1
            return try addReviewStub?.get() ?? ()
        }
        
        //MARK: - Favorite
        private(set) var isFavoriteCallCount = 0
        private(set) var saveCallCount = 0
        private(set) var removeCallCount = 0
        
        var isFavoriteStub: Result<Bool, Error> = .success(false)
        var saveStub: Result<Void, Error> = .success(())
        var removeStub: Result<Void, Error> = .success(())
        
        func save(_ restaurant: RestaurantModel) async throws {
             saveCallCount += 1
            _ = try saveStub.get()
        }
        
        func remove(id: String) async throws {
            removeCallCount += 1
            _ = try removeStub.get()
        }
        
        func isFavorite(id: String) async throws -> Bool {
            isFavoriteCallCount += 1
            return try isFavoriteStub.get()
        }
        
    }
}
