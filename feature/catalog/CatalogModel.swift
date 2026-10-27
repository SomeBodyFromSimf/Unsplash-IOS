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
    private var nextPage = 1
    private let pageSize = 20

    private(set) var hasMore = true
    private(set) var isLoadingNextPage = false
    private(set) var nextPageError: Error?
    private(set) var state: CatalogState = .loading

    init(photoApi: any PhotoApi) {
        self.photoApi = photoApi
    }

    func loadInitialPageIfNeeded() async {
        if case .success = state { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoadingNextPage, hasMore else { return }

        let previousPhotos: [PhotoUiModel]
        if case .success(let photos) = state {
            previousPhotos = photos
        } else {
            previousPhotos = []
            state = .loading
        }

        isLoadingNextPage = true
        nextPageError = nil
        defer { isLoadingNextPage = false }

        do {
            let photoModels = try await photoApi.fetchPhotos(page: nextPage, pageSize: pageSize)
            try Task.checkCancellation()

            var knownIDs = Set(previousPhotos.map(\.id))
            let photos = photoModels.compactMap { model -> PhotoUiModel? in
                guard let url = URL(string: model.imageUrl),
                      knownIDs.insert(model.id).inserted else { return nil }
                return PhotoUiModel(
                    id: model.id,
                    title: model.title,
                    authorName: model.authorName,
                    imageUrl: url,
                    imageAspectRatio: CGSize(width: model.width, height: model.height),
                    isFavorite: false
                )
            }

            state = .success(previousPhotos + photos)
            hasMore = !photoModels.isEmpty
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
}

enum CatalogState {
    case loading
    case error(Error)
    case success([PhotoUiModel])
}
