//
//  RestaurantListPresenterTests.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import RxSwift
import RxTest
import XCTest
import RestaurantApp

@MainActor
final class RestaurantListPresenterTests: XCTestCase {
    
    func test_init_doesNotMessagesAndShowLoading() {
        let (_, spy, _) = makeSUT()
        
        XCTAssertEqual(spy.interactorCallCount, 0)
        XCTAssertEqual(spy.interactorMessages, [])
        XCTAssertEqual(spy.viewMessages, [])
        XCTAssertNil(spy.routerId)
    }
    
    func test_didSearch_requestSearchWithInitialPageAndShowsLoading() {
        let (sut, spy, scheduler) = makeSUT()
        let query = "Melting"
        
        sut.didSearch(query: query)
        scheduler.advanceTo(300)
        
        XCTAssertEqual(spy.viewMessages, [.showLoading])
        XCTAssertEqual(spy.interactorMessages.first, .request(query: query))
    }
    
    func test_didSearch_deliversErrorOnFailure() {
        let (sut, spy, scheduler) = makeSUT()
        let expectedError = anyError()
        
        spy.interactorStub = .error(expectedError)
        
        sut.didSearch(query: "")
        scheduler.advanceTo(300)
        
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showError(expectedError.localizedDescription)
        ])
    }
    
    func test_didSearch_deliversUsersOnSuccess() {
        let (sut, spy, scheduler) = makeSUT()
        let restaurant = RestaurantModel(id: "an id", name: "a name", description: "a description", pictureURL: anyURL(), city: "a city", rating: "a rating")
        spy.interactorStub = .just([restaurant])
        
        sut.didSearch(query: "")
        scheduler.advanceTo(300)
        
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showRestaurants([restaurant])
        ])
    }
    
    func test_didSearch_debouncesFastConsecutiveQueries() {
        let (sut, spy, scheduler) = makeSUT()
        
        sut.didSearch(query: "mel")
        scheduler.advanceTo(100)
        XCTAssertEqual(spy.interactorCallCount, 0)
        
        sut.didSearch(query: "melti")
        scheduler.advanceTo(200)
        XCTAssertEqual(spy.interactorCallCount, 0)
        
        sut.didSearch(query: "melting")
        scheduler.advanceTo(299)
        XCTAssertEqual(spy.interactorCallCount, 0)
        
        scheduler.advanceTo(500)
        
        XCTAssertEqual(spy.interactorMessages.last, .request(query: "melting"))
        XCTAssertEqual(spy.interactorCallCount, 1)
    }
    
    func test_didSearch_doesNotDuplicateSameSearch() {
        let (sut, spy, scheduler) = makeSUT()

        sut.didSearch(query: "melting")
        scheduler.advanceTo(300)
        XCTAssertEqual(spy.interactorCallCount, 1)
        
        sut.didSearch(query: "melting")
        scheduler.advanceTo(600)
        XCTAssertEqual(spy.interactorCallCount, 1)
    }
    
    func test_viewDidLoad_deliversErrorOnFailure() {
        let (sut, spy, _) = makeSUT()
        let expectedError = anyError()
        
        spy.interactorStub = .error(expectedError)
        sut.viewDidLoad()
        
        XCTAssertEqual(spy.interactorCallCount, 1)
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showError(expectedError.localizedDescription)
        ])
    }
    
    func test_viewDidLoad_deliversResultOnSuccess() {
        let (sut, spy, _) = makeSUT()
        let restaurant = RestaurantModel(id: "an id", name: "a name", description: "a description", pictureURL: anyURL(), city: "a city", rating: "a rating")
        spy.interactorStub = .just([restaurant])
        
        sut.viewDidLoad()
     
        XCTAssertEqual(spy.interactorCallCount, 1)
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showRestaurants([restaurant])
        ])
    }
    
    func test_didCancelSearch_restoresIntialUsers() {
        let (sut, spy, scheduler) = makeSUT()
        let initialResult = RestaurantModel(id: "an id", name: "a name", description: "a description", pictureURL: anyURL(), city: "a city", rating: "a rating")
        let searchedResult = RestaurantModel(id: "an id", name: "melting pot", description: "a description", pictureURL: anyURL(), city: "a city", rating: "a rating")
        
        spy.interactorStub = .just([initialResult])
        sut.viewDidLoad()
        
        spy.interactorStub = .just([searchedResult])
        sut.didSearch(query: "melting")
        scheduler.advanceTo(500)
        
        sut.didCancelSearch()
        
        XCTAssertEqual(spy.viewMessages.last, .showRestaurants([initialResult]))
    }
    
    func test_didSelectRestaurant_shouldParseId() {
        let (sut, spy, _) = makeSUT()
        
        sut.didSelectRestaurant(id: "fufufafa")
        
        XCTAssertEqual(spy.routerId, "fufufafa")
    }
    
    func test_view_shouldHaveBeenDeallocated() {
        let (sut, _, _) = makeSUT()
        
        
        do {
            let tempView = ViewSpy()
            sut.view = tempView
            XCTAssertNotNil(sut.view)
        }
        
        XCTAssertNil(sut.view)
    }
    
    //MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: RestaurantListPresenter,
        spy: ViewSpy,
        scheduler: TestScheduler
    ) {
        let scheduler = TestScheduler(initialClock: 0)
        let sut = RestaurantListPresenter(scheduler: scheduler, dueTime: .seconds(300))
        let spy = ViewSpy()
        
        sut.view = spy
        sut.interactor = spy
        sut.router = spy
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
    
    private class ViewSpy: RestaurantListViewProtocol, RestaurantListInteractorProtocol, RestaurantListRouterProtocol {
        // MARK: - View
        enum ViewMessage: Equatable {
            case showLoading
            case hideLoading
            case showRestaurants(_ restaurants: [RestaurantModel])
            case showError(_ message: String)
        }
        
        private(set) var viewMessages = [ViewMessage]()
        
        func showLoading() {
            viewMessages.append(.showLoading)
        }
        
        func hideLoading() {
            viewMessages.append(.hideLoading)
        }
        
        func showRestaurants(_ restaurants: [RestaurantModel]) {
            viewMessages.append(.showRestaurants(restaurants))
        }
        
        func showError(_ message: String) {
            viewMessages.append(.showError(message))
        }
        
        // MARK: - Interactor
        
        enum InteractorMessage: Equatable {
            case request(query: String)
        }
        
        private(set) var interactorCallCount = 0
        private(set) var interactorMessages = [InteractorMessage]()
        var interactorStub: Single<[RestaurantModel]> = .never()
        
        func fetchRestaurant(query: String) -> Single<[RestaurantModel]> {
            interactorMessages.append(.request(query: query))
            interactorCallCount += 1
            return interactorStub
        }
        
        // MARK: - Router
        private(set) var routerId: String?
        
        static func createModule() -> UIViewController {
            return UIViewController()
        }
        
        func navigateToDetail(view: (any RestaurantListViewProtocol)?, id: String) {
            routerId = id
        }
    }
}
