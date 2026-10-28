import Domain
import Testing
import ui
@testable import catalog
@testable import favorites

@MainActor
struct FavoritesErrorTests {
    @Test func favoritesKeepPhotosOnReadFailureAndCanRetry() async {
        let storage = FailingFavoritesStorage()
        let model = FavoriteModel(itemsStorage: storage)
        await model.collectFavorites()
        #expect(model.photos.map(\.id) == [storage.photo.id])

        storage.failsReading = true
        await model.collectFavorites()
        #expect(model.favoritesObservationError != nil)
        #expect(model.photos.map(\.id) == [storage.photo.id])

        storage.failsReading = false
        await model.collectFavorites()
        #expect(model.favoritesObservationError == nil)

        model.toggleFavorite(id: storage.photo.id, add: false)
        #expect(model.showsFavoriteWriteError)
        #expect(model.photos.map(\.id) == [storage.photo.id])
    }

    @Test func catalogReportsFailuresAndRestoresObservation() async {
        let storage = FailingFavoritesStorage()
        let model = CatalogModel(photoApi: SinglePhotoApi(photo: storage.photo), itemsStorage: storage)
        await model.loadInitialPageIfNeeded()
        await model.collectFavorites()
        #expect(model.uiPhotos.first?.isFavorite == true)

        storage.failsReading = true
        await model.collectFavorites()
        #expect(model.favoritesObservationError != nil)
        #expect(model.uiPhotos.first?.isFavorite == true)

        storage.failsReading = false
        await model.collectFavorites()
        #expect(model.favoritesObservationError == nil)

        model.toggleFavorite(id: storage.photo.id, add: false)
        #expect(model.showsFavoriteWriteError)
        #expect(model.uiPhotos.first?.isFavorite == true)
    }
}

@MainActor
private final class FailingFavoritesStorage: ItemsStorage {
    var failsReading = false
    let photo = PhotoModel(
        id: "favorite", title: "Photo", authorName: "Author",
        imageUrl: "https://example.com/photo.jpg", width: 100, height: 200
    )

    func observeFavorites() -> AsyncThrowingStream<[PhotoModel], Error> {
        let (stream, continuation) = AsyncThrowingStream<[PhotoModel], Error>.makeStream()
        if failsReading {
            continuation.finish(throwing: StorageFailure.unavailable)
        } else {
            continuation.yield([photo])
            continuation.finish()
        }
        return stream
    }

    func getFavorites() throws -> [PhotoModel] { [photo] }
    func getFavoriteIds() throws -> [String] { [photo.id] }
    func addIntoStorage(model: PhotoModel) throws { throw StorageFailure.unavailable }
    func deleteFromStorage(id: String) throws { throw StorageFailure.unavailable }
}

private enum StorageFailure: Error {
    case unavailable
}

private struct SinglePhotoApi: PhotoApi {
    let photo: PhotoModel

    func fetchPhotos(page: Int, pageSize: Int) async throws -> [PhotoModel] { [photo] }
}
