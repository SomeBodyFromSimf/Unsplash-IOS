//
//  PhotoModel.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 04.10.2026.
//

import Foundation

public struct PhotoUiModel: Identifiable {
    public let id: String
    public let title: String
    public let authorName: String
    public let imageUrl: URL
    public let imageAspectRatio: CGSize
    public let isFavorite: Bool

    public init(id: String, title: String, authorName: String, imageUrl: URL, imageAspectRatio: CGSize, isFavorite: Bool) {
        self.id = id
        self.title = title
        self.authorName = authorName
        self.imageUrl = imageUrl
        self.imageAspectRatio = imageAspectRatio
        self.isFavorite = isFavorite
    }
}
