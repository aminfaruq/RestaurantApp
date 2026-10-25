//
//  RestaurantListRouter.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import UIKit

final class RestaurantListRouter: RestaurantListRouterProtocol {
    static func createModule(
        loader: RestaurantListLoader
    ) -> UIViewController {
        let view = RestaurantListViewController()
        let presenter = RestaurantListPresenter()
        let interactor = RestaurantListInteractor(loader: loader)
        let router = RestaurantListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        return view
    }
    
    func navigateToDetail(view: (any RestaurantListViewProtocol)?, id: String) {
        guard let sourceView = view as? UIViewController else { return }
        let view = RestaurantDetailRouter.createModule(id: id)
        sourceView.navigationController?.pushViewController(view, animated: true)
    }
}
