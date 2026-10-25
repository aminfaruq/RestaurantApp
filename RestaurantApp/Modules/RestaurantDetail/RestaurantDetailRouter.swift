//
//  RestaurantDetailRouter.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import UIKit

final class RestaurantDetailRouter: RestaurantDetailRouterProtocol {
    
    static func createModule(id: String) -> UIViewController {
        let view = RestaurantDetailViewController()
        let presenter = RestaurantDetailPresenter(id: id)
        let url = URL(string: "https://restaurant-api.dicoding.dev")!
        let client = URLSessionHTTPClient()
        let loader = RemoteRestaurantDetailLoader(url: url, client: client)
        let interactor = RestaurantDetailInteractor(loader: loader)
        let router = RestaurantDetailRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        return view
    }
}
