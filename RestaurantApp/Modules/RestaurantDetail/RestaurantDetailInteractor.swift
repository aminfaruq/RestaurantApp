//
//  RestaurantDetailInteractor.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import RxSwift

public final class RestaurantDetailInteractor: RestaurantDetailInteractorProtocol {
    
    private let loader: RestaurantDetailLoader
    
    public init(loader: RestaurantDetailLoader) {
        self.loader = loader
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
}
