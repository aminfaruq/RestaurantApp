//
//  AppRouter.swift
//  RestaurantApp
//
//  Created by Amin faruq on 26/10/26.
//

import UIKit
import Foundation

public final class AppRouter {
    
    public static func createModule(
        baseURL: URL = URL(string: "https://restaurant-api.dicoding.dev")!
    ) -> UITabBarController {
        let client = URLSessionHTTPClient()
        let remoteLoader = RemoteRestaurantListLoader(url: baseURL, client: client)
        let remoteRestaurantListVC = RestaurantListRouter.createModule(loader: remoteLoader)
        let remoteRestaurantListNav = UINavigationController(rootViewController: remoteRestaurantListVC)
        remoteRestaurantListNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        let store = RealmFavoriteRestaurantStore()
        let localLoader = LocalRestaurantListLoader(store: store)
        let localRestaurantListVC = RestaurantListRouter.createModule(loader: localLoader)
        let localRestautantListNav = UINavigationController(rootViewController: localRestaurantListVC)
        localRestautantListNav.tabBarItem = UITabBarItem(
            title: "Favorite",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )
        
        let tabBarController = MainTabBarController(viewControllers: [remoteRestaurantListNav, localRestautantListNav])
        return tabBarController
    }
}
