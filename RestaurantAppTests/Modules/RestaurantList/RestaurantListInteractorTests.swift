//
//  RestaurantListInteractorTests.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//
import RestaurantApp
import RxSwift
import XCTest

final class RestaurantListInteractorTests: XCTestCase {
    
    private let disposeBag = DisposeBag()
    
    func test_init_doesNotRequestFromLoader() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.loadCallCount, 0)
    }
    
    @MainActor
    func test_fetchRestaurant_deliversErrorOnFailure() async {
        let (sut, spy) = makeSUT()
        let expectedError = anyError()
        spy.stub(with: .failure(expectedError))
        
        let exp = expectation(description: "Wait from Single Failure")
        var receivedError: NSError?
        
        sut.fetchRestaurant()
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
    }
    
    @MainActor
    func test_fetchRestaurant_deliverRestaurantOnSuccess() async {
        let (sut, spy) = makeSUT()
        let restaurant = RestaurantModel(id: "an id", name: "a name", description: "a description", pictureURL: anyURL(), city: "a city", rating: "a rating")
        spy.stub(with: .success([restaurant]))
        
        let exp = expectation(description: "Wait from Single Success")
        var receivedResult = [RestaurantModel]()
        
        sut.fetchRestaurant()
            .subscribe(
                onSuccess: { result in
                    receivedResult = result
                    exp.fulfill()
                }
            )
            .disposed(by: disposeBag)
        
        await fulfillment(of: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedResult, [restaurant])
    }
    
    //MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RestaurantListInteractor, spy: RestaurantListLoaderSpy) {
        let spy = RestaurantListLoaderSpy()
        let sut = RestaurantListInteractor(loader: spy)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, spy)
    }
    
    private class RestaurantListLoaderSpy: RestaurantListLoader {
        private(set) var loadCallCount = 0
        private var stub: Result<[RestaurantModel], Error>?
        
        func stub(with result: Result<[RestaurantModel], Error>) {
            self.stub = result
        }
        
        func loadRestaurant(query: String) async throws -> [RestaurantModel] {
            loadCallCount += 1
            return try stub?.get() ?? []
        }
    }
}
