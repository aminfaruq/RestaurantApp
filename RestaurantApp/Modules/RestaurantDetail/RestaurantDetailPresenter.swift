//
//  RestaurantDetailPresenter.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import Foundation
import RxSwift

public final class RestaurantDetailPresenter: RestaurantDetailPresenterProtocol {
    public weak var view: RestaurantDetailViewProtocol?
    public var interactor: RestaurantDetailInteractorProtocol?
    public var router: RestaurantDetailRouterProtocol?
    
    private let disposeBag = DisposeBag()
    private var currentRestaurant: RestaurantModel?
    
    private let id: String
    
    public init(id: String) {
        self.id = id
    }
        
    public func viewDidLoad() {
        requestDetail()
        checkFavoriteStatus()
    }
    
    public func didAddReview(_ review: AddReviewBody) {
        view?.showLoading()
        
        interactor?.addReview(body: review)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self = self else { return }
                    view?.hideLoading()
                    view?.showPopup()
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    view?.hideLoading()
                    view?.showError(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    public func didDismissPopup() {
        requestDetail()
    }
    
    public func didPullToRefresh() {
        requestDetail()
    }
    
    public func didTapFavoriteButton() {
        guard let currentRestaurant = currentRestaurant else { return }
        
        interactor?.toggleFavorite(restaurant: currentRestaurant)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] isFavorite in
                    guard let self = self else { return }
                    view?.setFavoriteStatus(isFavorite: isFavorite)
                },
                onFailure: { [weak self] error in
                    guard let self = self else { return }
                    view?.showError(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func checkFavoriteStatus() {
        interactor?.isFavorite(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] isFavorite in
                    self?.view?.setFavoriteStatus(isFavorite: isFavorite)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func requestDetail() {
        view?.showLoading()
        
        interactor?.fetchRestaurantDetail(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] result in
                    guard let self = self else { return }
                    view?.hideLoading()
                    self.currentRestaurant = result.toRestaurantModel()
                    let menus = (result.menus.foods + result.menus.drinks).map({ $0.name })
                    view?.showMenus(menus)
                    view?.showRestaurant(result)
                },
                onFailure: { [weak self] error in
                    guard let self = self else { return }
                    view?.hideLoading()
                    view?.showError(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
    }
    
}
