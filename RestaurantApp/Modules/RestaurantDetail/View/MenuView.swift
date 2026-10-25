//
//  MenuView.swift
//  RestaurantApp
//
//  Created by Amin faruq on 25/10/26.
//

import UIKit

final class MenuView: UIView {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        imageView.image = UIImage(systemName: "fork.knife", withConfiguration: config)
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    convenience init(title: String) {
        self.init(frame: .zero)
        configure(with: title)
    }
    
    // MARK: - Public Configuration
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Setup Layout
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 14
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        
        iconContainerView.addSubview(iconImageView)
        addSubview(iconContainerView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 100),
            
            iconContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            iconContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 44),
            iconContainerView.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])
    }
}
