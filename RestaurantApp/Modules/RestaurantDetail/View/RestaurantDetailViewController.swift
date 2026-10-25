//
//  RestaurantDetailViewController.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//
import Kingfisher
import UIKit

class RestaurantDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var horizontalStackView: UIStackView!
    @IBOutlet weak var customerReviewTableView: SelfSizingTableView!
    @IBOutlet weak var addReviewLabel: UILabel!
    
    private var customerReviews = [CustomerReviewModel]()
    private var restaurantId: String = ""
    private var favoriteBarButtonItem: UIBarButtonItem?
    
    private let refreshControl = UIRefreshControl()
    
    public var presenter: RestaurantDetailPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true

        presenter?.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupView() {
        scrollView.refreshControl = refreshControl
        customerReviewTableView.delegate = self
        customerReviewTableView.dataSource = self
        customerReviewTableView.register(UINib(nibName: "CustomerReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomerReviewTableViewCell")
        customerReviewTableView.isScrollEnabled = false
        customerReviewTableView.rowHeight = UITableView.automaticDimension
        customerReviewTableView.estimatedRowHeight = 100
        customerReviewTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        
        horizontalStackView.spacing = 12
        horizontalStackView.distribution = .fillProportionally
        
        addReviewLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddReview))
        addReviewLabel.addGestureRecognizer(tapGesture)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        favoriteBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(didTapFavorite)
        )
        navigationItem.rightBarButtonItem = favoriteBarButtonItem
    }
    
    @objc func didTapFavorite() {
        presenter?.didTapFavoriteButton()
    }
    
    @objc func pullToRefresh() {
        presenter?.didPullToRefresh()
    }
    
    @objc func didTapAddReview() {
        let alert = UIAlertController(
            title: "Add Review",
            message: "Share your experience with this restaurant",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Your Name"
            textField.autocapitalizationType = .words
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Your Review..."
            textField.autocapitalizationType = .sentences
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let self = self,
                  let name = alert.textFields?[0].text, !name.trimmingCharacters(in: .whitespaces).isEmpty,
                  let review = alert.textFields?[1].text, !review.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            
            let body = AddReviewBody(id: self.restaurantId, name: name, review: review)
            self.presenter?.didAddReview(body)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
}

extension RestaurantDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customerReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerReviewTableViewCell", for: indexPath) as? CustomerReviewTableViewCell else { return UITableViewCell() }
        cell.configure(customerReviews[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension RestaurantDetailViewController: RestaurantDetailViewProtocol {
    
    func showLoading() {
        contentView.isHidden = true
        activityIndicatorView.startAnimating()
    }
    
    func hideLoading() {
        contentView.isHidden = false
        refreshControl.endRefreshing()
        activityIndicatorView.stopAnimating()
    }
    
    func showRestaurant(_ restaurant: RestaurantDetailModel) {
        self.restaurantId = restaurant.id
        self.customerReviews = restaurant.customerReviews
        self.imageView.kf.indicatorType = .activity
        self.imageView.kf.setImage(with: restaurant.pictureURL)
        self.restaurantNameLabel.text = restaurant.name
        self.cityLabel.text = restaurant.city
        self.descriptionLabel.text = restaurant.description
        self.customerReviewTableView.reloadData()
        self.customerReviewTableView.layoutIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    func showMenus(_ results: [String]) {
        let space = UIView()
        space.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        
        horizontalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        horizontalStackView.addArrangedSubview(space)
        results.forEach { menuName in
            let card = MenuView(title: menuName)
            horizontalStackView.addArrangedSubview(card)
        }
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
    
    func showPopup() {
        let alert = UIAlertController(title: "Success", message: "Your review has been sent!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.presenter?.didDismissPopup()
        }))
        present(alert, animated: true)
    }
    
    func setFavoriteStatus(isFavorite: Bool) {
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteBarButtonItem?.image = UIImage(systemName: imageName)
        favoriteBarButtonItem?.tintColor = isFavorite ? .systemRed : .label
    }
}

