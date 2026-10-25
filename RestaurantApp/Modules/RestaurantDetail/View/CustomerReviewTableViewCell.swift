//
//  CustomerReviewTableViewCell.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

import UIKit

class CustomerReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var initialNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarContainerView.layer.cornerRadius = 18
        avatarContainerView.clipsToBounds = true
        avatarContainerView.backgroundColor = .systemGray5
        initialNameLabel.textColor = .white
    }
    
    func configure(_ result: CustomerReviewModel) {
        nameLabel.text = result.name
        dateLabel.text = result.date
        reviewLabel.text = result.review
        initialNameLabel.text = result.name.avatarInitials
        
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemPink]
        let index = abs(result.name.hashValue) % colors.count
        avatarContainerView.backgroundColor = colors[index]
    }
}


private extension String {
    var avatarInitials: String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = trimmed.split(separator: " ").map(String.init)
        
        if words.count >= 2 {
            let first = words[0].prefix(1)
            let second = words[1].prefix(1)
            return "\(first)\(second)".uppercased()
        } else if let word = words.first, !word.isEmpty {
            let first = word.prefix(1)
            let last = word.count > 1 ? String(word.suffix(1)) : ""
            return "\(first)\(last)".uppercased()
        }
        
        return "?"
    }
}
