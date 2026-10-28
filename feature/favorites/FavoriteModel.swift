//
//  CatalogModel.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 29.09.2026.
//
import SwiftUI
import Observation
import Domain
import ui

@MainActor
@Observable
final class FavoriteModel {
    private let itemsStorage: any ItemsStorage
    private(set) var favoritesObservationError: Error?
    var showsFavoriteWriteError = false
    
    private var favoriteList: [PhotoModel] = []
    
    var photos: [PhotoUiModel] {
        favoriteList.compactMap { model -> PhotoUiModel? in
            guard let url = URL(string: model.imageUrl) else { return nil }
            return PhotoUiModel(id: model.id,
                         title: model.title,
                         authorName: model.authorName,
                         imageUrl: url,
                         imageAspectRatio: CGSize(width: model.width, height: model.height),
                         isFavorite: true)
        }
    }
    
    init(itemsStorage: any ItemsStorage) {
        self.itemsStorage = itemsStorage
    }
    
    func collectFavorites() async {
        favoritesObservationError = nil
        do {
            for try await list in itemsStorage.observeFavorites() {
                guard !Task.isCancelled else { return }
                favoriteList = list
            }
        } catch {
            guard !Task.isCancelled, !(error is CancellationError) else { return }
            favoritesObservationError = error
            print(error.localizedDescription)
        }
    }
    
    func toggleFavorite(id: String ,add: Bool) {
        do {
            if add {
                guard let item = favoriteList.first(where: { $0.id == id }) else { return }
                try itemsStorage.addIntoStorage(model: item)
            } else {
                try itemsStorage.deleteFromStorage(id: id)
            }
        } catch {
            showsFavoriteWriteError = true
            print(error.localizedDescription)
        }
    }
}
