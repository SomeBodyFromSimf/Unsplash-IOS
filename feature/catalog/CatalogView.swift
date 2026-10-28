//
//  CatalogView.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 29.09.2026.
//
import SwiftUI
import ui

public struct CatalogView: View {
    @State private var favoritesReloadID = 0
    @State private var model: CatalogModel
    @State private var reloadID = 0

    init(model: CatalogModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle(Text(.mainText))
        }
        .safeAreaInset(edge: .top) {
            if model.favoritesObservationError != nil {
                VStack(spacing: 8) {
                    Text(.favoritesObservationError)
                        .multilineTextAlignment(.center)
                    Button {
                        favoritesReloadID += 1
                    } label: {
                        Text(.favoritesRetry)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
            }
        }
        .alert(Text(.favoritesWriteErrorTitle), isPresented: $model.showsFavoriteWriteError) {
            Button(role: .cancel) {} label: {
                Text(.favoritesDismiss)
            }
        } message: {
            Text(.favoritesWriteErrorDescription)
        }
        .task(id: favoritesReloadID) {
            await model.collectFavorites()
        }
        .task(id: reloadID) {
            await model.loadInitialPageIfNeeded()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.state {
        case .loading:
            ProgressView {
                Text(.catalogLoading)
            }
        case .error:
            ContentUnavailableView {
                Label {
                    Text(.catalogErrorTitle)
                } icon: {
                    Image(systemName: "wifi.exclamationmark")
                }
            } description: {
                Text(.catalogErrorDescription)
            } actions: {
                Button {
                    reloadID += 1
                } label: {
                    Text(.catalogRetry)
                }
                .buttonStyle(.borderedProminent)
            }
        case .success:
            ScrollView {
                let photos = model.uiPhotos
                LazyVStack(spacing: 16) {
                    if photos.isEmpty {
                        ContentUnavailableView {
                            Label {
                                Text(.catalogEmptyTitle)
                            } icon: {
                                Image(systemName: "photo.on.rectangle")
                            }
                        } description: {
                            Text(.catalogEmptyDescription)
                        }
                    }

                    ForEach(photos) { photo in
                        PhotoCardView(uiModel: photo, onFavoriteTap: { model.toggleFavorite(id: photo.id, add: !photo.isFavorite) })
                    }

                    paginationFooter
                }
                .padding(16)
            }
        }
    }

    @ViewBuilder
    private var paginationFooter: some View {
        if model.isLoadingNextPage {
            ProgressView {
                Text(.catalogLoading)
            }
            .padding()
        } else if model.hasMore {
            VStack(spacing: 8) {
                if model.nextPageError != nil {
                    Text(.catalogNextPageError)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                Button {
                    Task {
                        await model.loadNextPage()
                    }
                } label: {
                    if model.nextPageError != nil {
                        Text(.catalogRetry)
                    } else {
                        Text(.catalogLoadMore)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
