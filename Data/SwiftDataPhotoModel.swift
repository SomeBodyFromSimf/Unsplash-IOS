//
//  PhotoDbModel.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 04.10.2026.
//

import SwiftData
import Foundation
import Domain

@Model
public final class SwiftDataPhotoModel {
    @Attribute(.unique) public var id: String
    var title: String
    var authorName: String
    var imageUrl: String
    var width: Int
    var height: Int
    var addedAt: Date
    
    public init(id: String, title: String, authorName: String, imageUrl: String, width: Int, height: Int, addedAt: Date) {
        self.id = id
        self.title = title
        self.authorName = authorName
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
        self.addedAt = addedAt
    }
}

extension PhotoModel {
    init(from model: SwiftDataPhotoModel) {
        self.init(id: model.id,
                  title: model.title,
                  authorName: model.authorName,
                  imageUrl: model.imageUrl,
                  width: model.width,
                  height: model.height)
    }
}

extension SwiftDataPhotoModel {
    convenience init(from model: PhotoModel) {
        self.init(id: model.id,
                  title: model.title,
                  authorName: model.authorName,
                  imageUrl: model.imageUrl,
                  width: model.width,
                  height: model.height,
                  addedAt: Date())
    }
}
