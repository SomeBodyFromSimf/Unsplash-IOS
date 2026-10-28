//
//  CatalogModel.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 29.09.2026.
//
import Observation
import CoreGraphics
import Domain
import Foundation
import ui

@MainActor
@Observable
final class CatalogModel {
    private let photoApi: any PhotoApi
    private let itemsStorage: any ItemsStorage
    private(set) var favoritesObservationError: Error?
    var showsFavoriteWriteError = false
    private var nextPage = 1
    private let pageSize = 20

    private(set) var hasMore = true
    private(set) var isLoadingNextPage = false
    private(set) var nextPageError: Error?
    private(set) var state: CatalogState = .loading
    
    private var photos: [PhotoModel] = []
    private var favoriteIds: Set<String> = []
    
    var uiPhotos: [PhotoUiModel] {
        photos.compactMap { model -> PhotoUiModel? in
            guard let url = URL(string: model.imageUrl) else { return nil }
            return PhotoUiModel(
                id: model.id,
                title: model.title,
                authorName: model.authorName,
                imageUrl: url,
                imageAspectRatio: CGSize(width: model.width, height: model.height),
                isFavorite: favoriteIds.contains(model.id)
            )
        }
    }
    

    init(photoApi: any PhotoApi, itemsStorage: any ItemsStorage) {
        self.photoApi = photoApi
        self.itemsStorage = itemsStorage
    }

    func loadInitialPageIfNeeded() async {
        if case .success = state { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoadingNextPage, hasMore else { return }

        if case .error = state {
            state = .loading
        }

        isLoadingNextPage = true
        nextPageError = nil
        defer { isLoadingNextPage = false }

        do {
            var photoModels = try await photoApi.fetchPhotos(page: nextPage, pageSize: pageSize)
            try Task.checkCancellation()
            hasMore = !photoModels.isEmpty

            var knownIDs = Set(photos.map(\.id))
            photoModels.removeAll { !knownIDs.insert($0.id).inserted }
            
            photos += photoModels

            state = .success
            nextPage += 1
        } catch {
            guard !Task.isCancelled, !(error is CancellationError) else { return }

            print("Photo loading failed:", String(reflecting: error))
            if case .success = state {
                nextPageError = error
            } else {
                state = .error(error)
            }
        }
    }
    
    func collectFavorites() async {
        favoritesObservationError = nil
        do {
            for try await list in itemsStorage.observeFavorites() {
                guard !Task.isCancelled else { return }
                favoriteIds = Set(list.map { $0.id })
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
                guard let item = photos.first(where: { $0.id == id }) else { return }
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

enum CatalogState {
    case loading
    case error(Error)
    case success
}
