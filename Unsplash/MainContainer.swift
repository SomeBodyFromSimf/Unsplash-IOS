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
    
    var body: some View {
        TabView(selection: $selectionTabState) {
            Tab(.tabFavorites, systemImage: "heart", value: .favorite) {
                FavoriteView()
            }
            Tab(.tabCatalog, systemImage: "photo.on.rectangle", value: .catalog) {
                CatalogView()
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
