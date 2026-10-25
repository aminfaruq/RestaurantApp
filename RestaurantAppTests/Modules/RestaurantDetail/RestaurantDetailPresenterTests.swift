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
        
        XCTAssertEqual(spy.interactorCallCount, 2)
        XCTAssertEqual(spy.interactorMessages, [
            .requestRestaurant(id: id),
            .isFavorite(id: id)]
        )
        XCTAssertTrue(spy.viewMessages.contains(.showError(expectedError.localizedDescription)))
    }
    
    func test_viewDidLoad_checksFavoriteStatus() {
        let id = "any-id"
        let (sut, spy) = makeSUT(id: id)
        spy.isFavoriteStub = .just(true)
        
        sut.viewDidLoad()
        
        XCTAssertTrue(spy.interactorMessages.contains(.isFavorite(id: id)))
        XCTAssertTrue(spy.viewMessages.contains(.setFavoriteStatus(isFavorite: true)))
    }
    
    func test_viewDidLoad_deliversRestaurantOnSuccess() {
        let id = "another-id"
        let (sut, spy) = makeSUT(id: id)
        let expectedResult = makeRestaurant(id: id)
        let expectedMenus = (expectedResult.menus.foods + expectedResult.menus.drinks).map { $0.name }
        spy.fetchRestaurantDetailStub = .just(expectedResult)
        sut.viewDidLoad()
        
        XCTAssertEqual(spy.interactorCallCount, 2)
        XCTAssertEqual(spy.interactorMessages, [.requestRestaurant(id: id), .isFavorite(id: id)])
        XCTAssertEqual(spy.viewMessages, [
            .showLoading,
            .hideLoading,
            .showMenus(expectedMenus),
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
    
    func test_didTapFavoriteButton_togglesFavoriteStatusOnSuccess() {
        let id = "any-id"
        let (sut, spy) = makeSUT(id: id)
        let restaurantDetail = makeRestaurant(id: id)
        let expectedRestaurant = restaurantDetail.toRestaurantModel()
        
        spy.fetchRestaurantDetailStub = .just(restaurantDetail)
        sut.viewDidLoad()
        
        spy.toggleFavoriteStub = .just(true)
        sut.didTapFavoriteButton()
        
        XCTAssertTrue(spy.interactorMessages.contains(.toggleFavorite(restaurant: expectedRestaurant)))
        XCTAssertTrue(spy.viewMessages.contains(.setFavoriteStatus(isFavorite: true)))
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
            case showMenus(_ results: [String])
            case showError(_ message: String)
            case showPopup
            case setFavoriteStatus(isFavorite: Bool)
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
        
        func showMenus(_ results: [String]) {
            viewMessages.append(.showMenus(results))
        }
        
        func showError(_ message: String) {
            viewMessages.append(.showError(message))
        }
        
        func showPopup() {
            viewMessages.append(.showPopup)
        }
        
        func setFavoriteStatus(isFavorite: Bool) {
            viewMessages.append(.setFavoriteStatus(isFavorite: isFavorite))
        }
        
        // MARK: Interactor
        enum InteractorMessage: Equatable {
            case requestRestaurant(id: String)
            case requestAddReview(body: AddReviewBody)
            case isFavorite(id: String)
            case toggleFavorite(restaurant: RestaurantModel)
        }
        
        var interactorCallCount: Int {
            interactorMessages.count
        }
        
        private(set) var interactorMessages = [InteractorMessage]()
        
        var fetchRestaurantDetailStub: Single<RestaurantDetailModel> = .never()
        var addReviewStub: Completable = .never()
        
        var isFavoriteStub: Single<Bool> = .never()
        var toggleFavoriteStub: Single<Bool> = .never()
        
        func fetchRestaurantDetail(id: String) -> Single<RestaurantDetailModel> {
            interactorMessages.append(.requestRestaurant(id: id))
            return fetchRestaurantDetailStub
        }
        
        func addReview(body: AddReviewBody) -> Completable {
            interactorMessages.append(.requestAddReview(body: body))
            return addReviewStub
        }
        
        func isFavorite(id: String) -> Single<Bool> {
            interactorMessages.append(.isFavorite(id: id))
            return isFavoriteStub
        }
        
        func toggleFavorite(restaurant: RestaurantModel) -> Single<Bool> {
            interactorMessages.append(.toggleFavorite(restaurant: restaurant))
            return toggleFavoriteStub
        }
        
        // MARK: Router
        static func createModule(id: String) -> UIViewController {
            return UIViewController()
        }
    }
    
}
