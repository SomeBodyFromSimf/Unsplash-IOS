//
//  CatalogView.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 29.09.2026.
//
import SwiftUI

public struct CatalogView : View {
    
    @State private var model: CatalogModel

    public init() {
        _model = State(initialValue: CatalogModel())
    }
    
    public var body: some View {
        Spacer()
        Text(.mainText)
        Spacer()
    }
}
