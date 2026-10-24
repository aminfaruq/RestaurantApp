//
//  RestaurantListPresenter.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import Foundation
import RxSwift

public final class RestaurantListPresenter: RestaurantListPresenterProtocol {
    public weak var view: RestaurantListViewProtocol?
    public var interactor: RestaurantListInteractorProtocol?
    public var router: RestaurantListRouterProtocol?
    
    // MARK: - Rx Setup
    private let searchSubject = PublishSubject<String>()
    private let scheduler: SchedulerType
    private let dueTime: RxTimeInterval
    private let disposeBag = DisposeBag()
    
    // MARK: - Initial Setup
    private var initialResult = [RestaurantModel]()
    
    public init(
        scheduler: SchedulerType = MainScheduler.instance,
        dueTime: RxTimeInterval = .milliseconds(300)
    ) {
        self.scheduler = scheduler
        self.dueTime = dueTime
        setupSearchPipeline()
    }
    
    public func viewDidLoad() {
        executeSearch(query: "")
    }
    
    public func didSearch(query: String) {
        searchSubject.onNext(query)
    }
    
    public func didCancelSearch() {
        view?.showRestaurants(initialResult)
    }
    
    public func pullToRefresh() {
        executeSearch(query: "")
    }
    
    public func didSelectRestaurant(id: String) {
        router?.navigateToDetail(view: view, id: id)
    }
    
    private func setupSearchPipeline() {
        searchSubject
            .debounce(dueTime, scheduler: scheduler)
            .distinctUntilChanged()
            .subscribe(
                onNext: { [weak self] query in
                    guard let self = self else { return }
                    
                    executeSearch(query: query)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func executeSearch(query: String) {
        view?.showLoading()
        
        interactor?.fetchRestaurant(query: query)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] result in
                    guard let self = self else { return }
                    view?.hideLoading()
                    
                    if query.isEmpty {
                        initialResult = result
                    }
                    
                    view?.showRestaurants(result)
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
