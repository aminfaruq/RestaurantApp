//
//  EmptyView.swift
//  RestaurantApp
//
//  Created by Amin faruq on 24/10/26.
//

import UIKit

class EmptyView: UIView {
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    static func instantiate() -> EmptyView {
        let nib = UINib(nibName: "EmptyView", bundle: nil)
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? EmptyView else {
            fatalError("Failed to load EmptyView from XIB")
        }
        return view
    }
    
    func configure(title: String) {
        emptyLabel.text = title.isEmpty ? "No Results": "No Results for `\(title)` "
    }
    
}
