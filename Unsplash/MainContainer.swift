//
//  MainContainer.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 18.09.2026.
//
import SwiftUI
import catalog
import favorites
import info

struct MainContainer: View {
    
    @State private var selectionTabState: SelectionTabState = .catalog
    
    private let catalogView: CatalogView
    private let favoriteView: FavoriteView

    init(catalogView: CatalogView, favoriteView: FavoriteView) {
        self.catalogView = catalogView
        self.favoriteView = favoriteView
    }
    
    var body: some View {
        TabView(selection: $selectionTabState) {
            Tab(.tabFavorites, systemImage: "heart", value: .favorite) {
                favoriteView
            }
            Tab(.tabCatalog, systemImage: "photo.on.rectangle", value: .catalog) {
                catalogView
            }
            Tab(.tabInfo, systemImage: "info.circle", value: .info) {
                InfoView()
            }
        }
    }
}

private enum SelectionTabState: Hashable {
    case favorite
    case catalog
    case info
}
