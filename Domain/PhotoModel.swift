//
//  PhotoModel.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 04.10.2026.
//

public nonisolated struct PhotoModel: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let authorName: String
    public let imageUrl: String
    public let width: Int
    public let height: Int

    public init(id: String, title: String, authorName: String, imageUrl: String, width: Int, height: Int) {
        self.id = id
        self.title = title
        self.authorName = authorName
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
    }
}
