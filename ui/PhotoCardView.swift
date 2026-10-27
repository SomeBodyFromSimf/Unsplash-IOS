//
//  PhotoCardView.swift
//  Unsplash
//
//  Created by Чистоусов Михаил on 04.10.2026.
//

import SwiftUI
internal import Kingfisher

public struct PhotoCardView: View {

    let uiModel: PhotoUiModel
    let onFavoriteTap: () -> Void

    public init(uiModel: PhotoUiModel, onFavoriteTap: @escaping () -> Void) {
        self.uiModel = uiModel
        self.onFavoriteTap = onFavoriteTap
    }

    public var body: some View {
        KFImage(uiModel.imageUrl)
            .resizable()
            .aspectRatio(uiModel.imageAspectRatio, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                Button(action: onFavoriteTap) {
                    Image(systemName: uiModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(uiModel.isFavorite ? .red : .white)
                }
                .padding(16)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(uiModel.title)
                        .font(.headline)
                    Text(uiModel.authorName)
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    @Previewable @State var isFavorite = true

    let model = PhotoUiModel(
        id: "",
        title: "some title",
        authorName: "Some author",
        imageUrl: URL(string: "https://images.unsplash.com/face-springmorning.jpg")!,
        imageAspectRatio: CGSize(width: 3, height: 2),
        isFavorite: isFavorite
    )
    PhotoCardView(uiModel: model, onFavoriteTap: { isFavorite.toggle() })
        .padding()
}
