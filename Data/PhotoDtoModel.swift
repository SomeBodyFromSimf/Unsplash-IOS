//
//  PhotoModel.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 04.10.2026.
//

nonisolated struct PhotoDtoModel: Decodable, Sendable {
    let id: String
    let width: Int
    let height: Int
    let description: String?

    let user: PhotoDtoUserModel
    let urls: PhotoDtoUrlModel
}

nonisolated struct PhotoDtoUserModel: Decodable, Sendable {
    let name: String
}

nonisolated struct PhotoDtoUrlModel: Decodable, Sendable {
    let regular: String
    let small: String
}
