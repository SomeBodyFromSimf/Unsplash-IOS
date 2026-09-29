//
//  CatalogView.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 29.09.2026.
//
import SwiftUI

public struct FavoriteView : View {
    
    @State private var model: FavoriteModel

    public init() {
        _model = State(initialValue: FavoriteModel())
    }
    
    public var body: some View {
        Spacer()
        Text(.mainText)
        Spacer()
    }
}
