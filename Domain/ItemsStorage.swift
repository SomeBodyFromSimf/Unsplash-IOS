//
//  ItemsStorage.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 28.10.2026.
//

@MainActor
public protocol ItemsStorage {
    func observeFavorites() -> AsyncThrowingStream<[PhotoModel], Error>

    func getFavorites() throws -> [PhotoModel]
    
    func getFavoriteIds() throws -> [String]
    
    func addIntoStorage(model: PhotoModel) throws
    
    func deleteFromStorage(id: String) throws
}
