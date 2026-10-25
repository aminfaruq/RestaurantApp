//
//  RestaurantListViewController.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import UIKit

class RestaurantListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    public var presenter: RestaurantListPresenterProtocol?
    
    private lazy var emptyView: EmptyView = {
        let view = EmptyView.instantiate()
        return view
    }()
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.delegate = self
        search.searchBar.sizeToFit()
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search restaurant..."
        search.hidesNavigationBarDuringPresentation = false
        return search
    }()
    
    private func updateEmptyState() {
        if results.isEmpty {
            emptyView.configure(title: currentQuery)
            tableView.backgroundView = emptyView
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
    
    private let refreshControl = UIRefreshControl()
    
    private var currentQuery = ""
    private var results = [RestaurantModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        presenter?.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "RestaurantTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RestaurantTableViewCell")
        tableView.tableHeaderView = searchController.searchBar
        tableView.refreshControl = refreshControl
        refreshControl.backgroundColor = .clear
        definesPresentationContext = true
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc func handleRefresh() {
        presenter?.pullToRefresh()
    }

}

extension RestaurantListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        self.currentQuery = query
        presenter?.didSearch(query: query)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.didCancelSearch()
    }
}

extension RestaurantListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell", for: indexPath) as? RestaurantTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(results[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        presenter?.didSelectRestaurant(id: results[indexPath.row].id)
    }
}

extension RestaurantListViewController: RestaurantListViewProtocol {
    func showLoading() {
        if results.isEmpty {
            activityIndicatorView.startAnimating()
            tableView.backgroundView = nil
            tableView.isHidden = true
        }
    }
    
    func hideLoading() {
        refreshControl.endRefreshing()
        activityIndicatorView.stopAnimating()
    }
    
    func showRestaurants(_ restaurants: [RestaurantModel]) {
        self.results = restaurants
        tableView.isHidden = false
        updateEmptyState()
        self.tableView.reloadData()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Something Went Wrong",
            message: message,
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.presenter?.viewDidLoad()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    
}
