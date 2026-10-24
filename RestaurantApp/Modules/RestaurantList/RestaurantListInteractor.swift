//
//  RestaurantListInteractor.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import RxSwift

public final class RestaurantListInteractor: RestaurantListInteractorProtocol {
    
    private let loader: RestaurantListLoader
    
    public init(loader: RestaurantListLoader) {
        self.loader = loader
    }
    
    public func fetchRestaurant(query: String = "") -> Single<[RestaurantModel]> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let task = Task {
                do {
                    let result = try await self.loader.loadRestaurant(query: query)
                    single(.success(result))
                } catch {
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
