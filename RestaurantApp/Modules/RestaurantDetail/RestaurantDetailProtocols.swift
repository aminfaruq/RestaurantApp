//
//  RestaurantDetailProtocols.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import RxSwift
import UIKit

//MARK: - Interactor
public protocol RestaurantDetailInteractorProtocol: AnyObject {
    func fetchRestaurantDetail(id: String) -> Single<RestaurantDetailModel>
    func addReview(body: AddReviewBody) -> Completable
}

//MARK: - View
public protocol RestaurantDetailViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showRestaurant(_ restaurant: RestaurantDetailModel)
    func showMenus(_ results: [String])
    func showError(_ message: String)
    func showPopup()
}

//MARK: - Router
public protocol RestaurantDetailRouterProtocol: AnyObject {
    static func createModule(id: String) -> UIViewController
}

//MARK: - Presenter
public protocol RestaurantDetailPresenterProtocol: AnyObject {
    var view: RestaurantDetailViewProtocol? { get set }
    var interactor: RestaurantDetailInteractorProtocol? { get set }
    var router: RestaurantDetailRouterProtocol? { get set }
    
    func viewDidLoad()
    func didAddReview(_ review: AddReviewBody)
    func didDismissPopup()
    func didPullToRefresh()
}
