//
//  RestaurantListProtocols.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import RxSwift
import UIKit

// MARK: - Interactor
public protocol RestaurantListInteractorProtocol: AnyObject {
    func fetchRestaurant(query: String) -> Single<[RestaurantModel]>
}

public extension RestaurantListInteractorProtocol {
    func fetchRestaurant(query: String = "") -> Single<[RestaurantModel]> {
        fetchRestaurant(query: query)
    }
}

// MARK: - View
public protocol RestaurantListViewProtocol: AnyObject {
    func showLoading()
    func hideLoading()
    func showRestaurants(_ restaurants: [RestaurantModel])
    func showError(_ message: String)
}

// MARK: - Router
public protocol RestaurantListRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    
    func navigateToDetail(view: RestaurantListViewProtocol?, id: String)
}

// MARK: - Presenter
public protocol RestaurantListPresenterProtocol: AnyObject {
    var view: RestaurantListViewProtocol? { get set }
    var interactor: RestaurantListInteractorProtocol? { get set }
    var router: RestaurantListRouterProtocol? { get set }
    
    func viewDidLoad()
    func didSearch(query: String)
    func didCancelSearch()
    func pullToRefresh()
    func didSelectRestaurant(id: String)
}
