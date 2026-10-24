//
//  RestaurantTableViewCell.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import UIKit
import Kingfisher

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        restaurantImageView.layer.cornerRadius = 8.0
    }

    func configure(_ result: RestaurantModel) {
        restaurantImageView.kf.indicatorType = .activity
        restaurantImageView.kf.setImage(with: result.pictureURL)
        restaurantLabel.text = result.name
        locationLabel.text = result.city
        ratingLabel.text = result.rating
    }
    
}
