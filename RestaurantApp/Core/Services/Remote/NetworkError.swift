//
//  NetworkError.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import Foundation

public enum NetworkError: Swift.Error, LocalizedError, Equatable {
    case connectivity
    case decodeError
    case invalidData
}
