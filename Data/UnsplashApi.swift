//
//  UnsplashApi.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 27.10.2026.
//

import Domain
import Foundation

public nonisolated final class UnsplashApi: PhotoApi {
    
    private enum Constants {
        static let url = URL(string: "https://api.unsplash.com")!
        static let photosPath = "photos"
        static let pageParam = "page"
        static let countParam = "per_page"
        
        static let authorizationHeader = "Authorization"
    }
    
    
    private let apiClient: APIClient
    private let clientId: String

    public init(
        apiClient: APIClient,
        clientId: String
    ) {
        self.apiClient = apiClient
        self.clientId = clientId
    }
    
    public func fetchPhotos(page: Int, pageSize: Int) async throws -> [PhotoModel] {
        let items = [
            URLQueryItem(name: Constants.pageParam, value: String(page)),
            URLQueryItem(name: Constants.countParam, value: String(pageSize))
        ]
        let destinationUrl = Constants.url
            .appending(path: Constants.photosPath)
            .appending(queryItems: items)
        var request = URLRequest(url: destinationUrl)
        request.setValue("Client-ID \(clientId)", forHTTPHeaderField: Constants.authorizationHeader)
        let requestModels = try await apiClient.get([PhotoDtoModel].self, from: request)
        return requestModels.map {
            PhotoModel(id: $0.id,
                       title: $0.description ?? "",
                       authorName: $0.user.name,
                       imageUrl: $0.urls.regular,
                       width: $0.width,
                       height: $0.height)
        }
    }
}
