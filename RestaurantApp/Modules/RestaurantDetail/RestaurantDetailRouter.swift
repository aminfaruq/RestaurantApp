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
        return view
    }
}
