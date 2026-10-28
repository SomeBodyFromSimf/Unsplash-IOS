//
//  CatalogView.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 29.09.2026.
//
import SwiftUI
import ui

public struct FavoriteView : View {
    
    @State private var favoritesReloadID = 0
    @State private var model: FavoriteModel
    
    init(model: FavoriteModel) {
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
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollView {
            let photos = model.photos
            LazyVStack(spacing: 16) {
                if photos.isEmpty && model.favoritesObservationError == nil {
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
            }
            .padding(16)
        }
    }
}
