//
//  CatalogView.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 29.09.2026.
//
import SwiftUI

public struct InfoView : View {
    
    @State private var model: InfoModel

    public init() {
        _model = State(initialValue: InfoModel())
    }
    
    public var body: some View {
        Spacer()
        Text(.mainText)
        Spacer()
    }
}
