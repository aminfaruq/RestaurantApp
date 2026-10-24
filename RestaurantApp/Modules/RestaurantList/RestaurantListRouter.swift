//
//  RestaurantListRouter.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import UIKit

final class RestaurantListRouter: RestaurantListRouterProtocol {
    static func createModule() -> UIViewController {
        let view = RestaurantListViewController()
        let presenter = RestaurantListPresenter()
        let url = URL(string: "https://restaurant-api.dicoding.dev")!
        let client = URLSessionHTTPClient()
        let loader = RemoteRestaurantListLoader(url: url, client: client)
        let interactor = RestaurantListInteractor(loader: loader)
        let router = RestaurantListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    func navigateToDetail(view: (any RestaurantListViewProtocol)?, id: String) {
        guard let sourceView = view as? UIViewController else { return }
    }
}
