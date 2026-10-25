//
//  RestaurantDetailInteractor.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import RxSwift

public final class RestaurantDetailInteractor: RestaurantDetailInteractorProtocol {
   
    private let loader: RestaurantDetailLoader
    private let favoriteManager: FavoriteRestaurantManager
    
    public init(loader: RestaurantDetailLoader, favoriteManager: FavoriteRestaurantManager) {
        self.loader = loader
        self.favoriteManager = favoriteManager
    }
    
    public func fetchRestaurantDetail(id: String) -> Single<RestaurantDetailModel> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let task = Task {
                do {
                    let result = try await self.loader.loadRestaurantDetail(id: id)
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
    
    public func addReview(body: AddReviewBody) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            let task = Task {
                do {
                    try await self.loader.addReview(review: body)
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    public func isFavorite(id: String) -> Single<Bool> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let task = Task {
                do {
                    let status = try await self.favoriteManager.isFavorite(id: id)
                    single(.success(status))
                } catch {
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    public func toggleFavorite(restaurant: RestaurantModel) -> Single<Bool> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            
            let task = Task {
                do {
                    let isFavorite = try await self.favoriteManager.isFavorite(id: restaurant.id)
                    
                    if isFavorite {
                        try await self.favoriteManager.remove(id: restaurant.id)
                        single(.success(false))
                    } else {
                        try await self.favoriteManager.save(restaurant)
                        single(.success(true))
                    }
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
