//
//  RestaurantDetailPresenterTests.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import RxSwift
import XCTest
import RestaurantApp

@MainActor
final class RestaurantDetailPresenterTests: XCTestCase {
    
    func test_init_doesNotMessagesAndShowLoading() {
        let (_, spy) = makeSUT()
        
        XCTAssertEqual(spy.interactorCallCount, 0)
        XCTAssertEqual(spy.interactorMessages, [])
        XCTAssertEqual(spy.viewMessages, [])
    }
    
    func test_viewDidLoad_deliversErrorOnFailure() {
        let id = "another-id"
        let (sut, spy) = makeSUT(id: id)
        let expectedError = anyError()
        
        spy.fetchRestaurantDetailStub = .error(expectedError)
        sut.viewDidLoad()
        
        XCTAssertEqual(spy.interactorCallCount, 1)
        XCTAssertEqual(spy.interactorMessages, [.requestRestaurant(id: id)])
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showError(expectedError.localizedDescription)
        ])
    }
    
    func test_viewDidLoad_deliversRestaurantOnSuccess() {
        let id = "another-id"
        let (sut, spy) = makeSUT(id: id)
        let expectedResult = makeRestaurant(id: id)
        
        spy.fetchRestaurantDetailStub = .just(expectedResult)
        sut.viewDidLoad()
        
        XCTAssertEqual(spy.interactorCallCount, 1)
        XCTAssertEqual(spy.interactorMessages, [.requestRestaurant(id: id)])
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showRestaurant(expectedResult)
        ])
    }
    
    func test_addReview_deliverErrorOnFailure() {
        let id = "another-id"
        let (sut, spy) = makeSUT(id: id)
        let expectedError = anyError()
        let request = AddReviewBody(id: id, name: "a name", review: "a review")
        
        spy.addReviewStub = .error(expectedError)
        sut.didAddReview(request)
        
        XCTAssertEqual(spy.interactorCallCount, 1)
        XCTAssertEqual(spy.interactorMessages, [.requestAddReview(body: request)])
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showError(expectedError.localizedDescription)
        ])
    }
    
    func test_addReview_deliverPopupWhenSuccess() {
        let id = "another-id"
        let (sut, spy) = makeSUT(id: id)
        let request = AddReviewBody(id: id, name: "a name", review: "a review")
        
        spy.addReviewStub = .empty()
        sut.didAddReview(request)
        
        XCTAssertEqual(spy.interactorCallCount, 1)
        XCTAssertEqual(spy.interactorMessages, [.requestAddReview(body: request)])
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showPopup
        ])
    }
    
    func test_didPullToRefresh_triggersInteractor() {
        let (sut, spy) = makeSUT()
        
        sut.didPullToRefresh()
        
        XCTAssertEqual(spy.interactorCallCount, 1)
    }
    
    func test_didDismissPopup_triggersInteractor() {
        let (sut, spy) = makeSUT()
        
        sut.didDismissPopup()
        
        XCTAssertEqual(spy.interactorCallCount, 1)
    }
    
    func test_view_shouldHaveBeenDeallocated() {
        let (sut, _) = makeSUT()
        
        do {
            let tempView = ViewSpy()
            sut.view = tempView
            XCTAssertNotNil(sut.view)
        }
        
        XCTAssertNil(sut.view)
    }
    
    //MARK: - Helpers
    private func makeSUT(
        id: String = "any-id",
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (
        sut: RestaurantDetailPresenter,
        spy: ViewSpy
    ) {
        let sut = RestaurantDetailPresenter(id: id)
        let spy = ViewSpy()
        
        sut.view = spy
        sut.interactor = spy
        sut.router = spy
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func makeRestaurant(id: String) -> RestaurantDetailModel {
        .init(
            id: id,
            name: "a name",
            description: "a description",
            city: "a city",
            address: "an adress",
            pictureURL: anyURL(),
            categories: [
                CategoryModel(name: "a category")
            ],
            menus: MenusModel(
                foods: [
                    CategoryModel(name: "a food")
                ],
                drinks: [
                    CategoryModel(name: "a drink")
                ]
            ),
            rating: "4.0",
            customerReviews: [
                CustomerReviewModel(name: "a name", review: "a review", date: "24 oct")
            ]
        )
    }
    
    private class ViewSpy: RestaurantDetailViewProtocol, RestaurantDetailInteractorProtocol, RestaurantDetailRouterProtocol {
        // MARK: View
        enum ViewMessage: Equatable {
            case showLoading
            case hideLoading
            case showRestaurant(_ restaurant: RestaurantDetailModel)
            case showError(_ message: String)
            case showPopup
        }
        
        private(set) var viewMessages = [ViewMessage]()
        
        func showLoading() {
            viewMessages.append(.showLoading)
        }
        
        func hideLoading() {
            viewMessages.append(.hideLoading)
        }
        
        func showRestaurant(_ restaurant: RestaurantDetailModel) {
            viewMessages.append(.showRestaurant(restaurant))
        }
        
        func showError(_ message: String) {
            viewMessages.append(.showError(message))
        }
        
        func showPopup() {
            viewMessages.append(.showPopup)
        }
        
        // MARK: Interactor
        enum InteractorMessage: Equatable {
            case requestRestaurant(id: String)
            case requestAddReview(body: AddReviewBody)
        }
        
        var interactorCallCount: Int {
            interactorMessages.count
        }
        
        private(set) var interactorMessages = [InteractorMessage]()
        
        var fetchRestaurantDetailStub: Single<RestaurantDetailModel> = .never()
        var addReviewStub: Completable = .never()
        
        func fetchRestaurantDetail(id: String) -> Single<RestaurantDetailModel> {
            interactorMessages.append(.requestRestaurant(id: id))
            return fetchRestaurantDetailStub
        }
        
        func addReview(body: AddReviewBody) -> Completable {
            interactorMessages.append(.requestAddReview(body: body))
            return addReviewStub
        }
        
        // MARK: Router
        static func createModule(id: String) -> UIViewController {
            return UIViewController()
        }
    }
    
}
