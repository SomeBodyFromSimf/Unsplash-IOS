//
//  PhotoApi.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 27.10.2026.
//

public protocol PhotoApi {
    func fetchPhotos(page: Int, pageSize: Int) async throws -> [PhotoModel]
}
