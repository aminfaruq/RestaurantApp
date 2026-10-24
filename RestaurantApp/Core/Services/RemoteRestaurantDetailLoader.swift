//
//  RemoteRestaurantDetailLoader.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import Foundation

public protocol RestaurantDetailLoader {
    func loadRestaurantDetail(id: String) async throws -> RestaurantDetailModel
    func addReview(review: AddReviewBody) async throws
}

public struct AddReviewBody: Hashable {
    public let id: String
    public let name: String
    public let review: String
    
    public init(id: String, name: String, review: String) {
        self.id = id
        self.name = name
        self.review = review
    }
}

public final class RemoteRestaurantDetailLoader: RestaurantDetailLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func loadRestaurantDetail(id: String) async throws -> RestaurantDetailModel {
        let requestedURL = url
            .appending(path: "detail")
            .appending(path: "\(id)")
        let response: HTTPURLResponse
        let data: Data
        do {
            (data, response) = try await client.get(from: requestedURL)
        } catch {
            throw NetworkError.connectivity
        }
        
        switch response.statusCode {
            case 200:
                guard let root = try? JSONDecoder().decode(RootDTO.self, from: data) else {
                    throw NetworkError.decodeError
                }
                return root.toModel()
            default:
                throw NetworkError.invalidData
        }
    }
    
    public func addReview(review: AddReviewBody) async throws {
        let requestedURL = url
            .appending(path: "review")
        let body = try makeBody(from: review)
        
        let response: HTTPURLResponse
        
        do {
            (_, response) = try await client.post(from: requestedURL, headers: nil, body: body)
        } catch {
            throw NetworkError.connectivity
        }
        
        switch response.statusCode {
            case 200:
                return
            default:
                throw NetworkError.invalidData
        }
    }
    
    private struct RootDTO: Decodable {
        private let id, name, description, city: String
        private let address, pictureId: String
        private let categories: [CategoryDTO]
        private let menus: MenusDTO
        private let rating: Double
        private let customerReviews: [CustomerReviewDTO]
        
        private static let imageBaseURL = URL(string: "https://restaurant-api.dicoding.dev/images/medium")
        
        func toModel() -> RestaurantDetailModel {
            .init(
                id: id,
                name: name,
                description: description,
                city: city,
                address: address,
                pictureURL: makeImageURL(from: pictureId),
                categories: categories.map({ $0.toModel() }),
                menus: menus.toModel(),
                rating: "\(rating)",
                customerReviews: customerReviews.map({ $0.toModel() }))
        }
        
        private func makeImageURL(from picture: String) -> URL {
            if let baseURL = RootDTO.imageBaseURL {
                return baseURL.appending(path: pictureId)
            }
            
            return URL(string: "about:blank") ?? URL(fileURLWithPath: "")
        }
    }
    
    private struct CategoryDTO: Decodable {
        private let name: String
        
        func toModel() -> CategoryModel {
            .init(name: name)
        }
    }
    
    private struct CustomerReviewDTO: Decodable {
        private let name, review, date: String
        
        func toModel() -> CustomerReviewModel {
            .init(name: name, review: review, date: date)
        }
    }

    private struct MenusDTO: Decodable {
        private let foods, drinks: [CategoryDTO]
        
        func toModel() -> MenusModel {
            .init(foods: foods.map({ $0.toModel() }), drinks: drinks.map({ $0.toModel() }))
        }
    }
    
    private func makeBody(from review: AddReviewBody) throws -> HTTPBody {
        let requestDTO = AddReviewRequestDTO(id: review.id, name: review.name, review: review.review)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        guard let data = try? encoder.encode(requestDTO) else {
            throw NetworkError.invalidData
        }
        return HTTPBody(data: data, contentType: .json)
    }
    
    private struct AddReviewRequestDTO: Encodable {
        let id: String
        let name: String
        let review: String
    }
}
