//
//  RestaurantDetailViewController.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//
import Kingfisher
import UIKit

class RestaurantDetailViewController: UIViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var horizontalStackView: UIStackView!
    @IBOutlet weak var customerReviewTableView: UITableView!
    @IBOutlet weak var addReviewLabel: UILabel!
    
    private var customerReviews = [CustomerReviewModel]()
    private var menus = [String]()
    
    public var presenter: RestaurantDetailPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        presenter?.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        customerReviewTableView.delegate = self
        customerReviewTableView.dataSource = self
        customerReviewTableView.register(UINib(nibName: "CustomerReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomerReviewTableViewCell")
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
}

extension RestaurantDetailViewController: RestaurantDetailViewProtocol {
    
    func showLoading() {
        contentView.isHidden = true
        activityIndicatorView.startAnimating()
    }
    
    func hideLoading() {
        contentView.isHidden = false
        activityIndicatorView.stopAnimating()
    }
    
    func showRestaurant(_ restaurant: RestaurantDetailModel) {
        self.customerReviews = restaurant.customerReviews
        self.imageView.kf.indicatorType = .activity
        self.imageView.kf.setImage(with: restaurant.pictureURL)
        self.restaurantNameLabel.text = restaurant.name
        self.cityLabel.text = restaurant.city
        self.descriptionLabel.text = restaurant.description
        self.customerReviewTableView.reloadData()
    }
    
    func showMenus(_ results: [String]) {
        self.menus = results
    }
    
    func showError(_ message: String) {
        print("💥 DEBUG ERROR DETAIL:", message)
    }
    
    func showPopup() {
        
    }
    
}
