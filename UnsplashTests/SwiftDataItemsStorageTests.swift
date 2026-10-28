import Data
import Domain
import SwiftData
import Testing

@MainActor
struct SwiftDataItemsStorageTests {
    @Test func observersReceiveInitialSnapshotAndSavedChanges() async throws {
        let container = try ModelContainer(
            for: SwiftDataPhotoModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let storage = SwiftDataItemsStorage(context: ModelContext(container))
        var first = storage.observeFavorites().makeAsyncIterator()
        var second = storage.observeFavorites().makeAsyncIterator()

        #expect(try await first.next()?.isEmpty == true)
        #expect(try await second.next()?.isEmpty == true)

        let photo = PhotoModel(
            id: "favorite", title: "Photo", authorName: "Author",
            imageUrl: "https://example.com/photo.jpg", width: 100, height: 200
        )
        try storage.addIntoStorage(model: photo)

        let firstUpdate = try await first.next()
        #expect(firstUpdate?.map(\.id) == [photo.id])
        #expect(try await second.next()?.map(\.id) == [photo.id])

        // Новый подписчик получает уже сохранённое состояние.
        var third = storage.observeFavorites().makeAsyncIterator()
        #expect(try await third.next()?.map(\.id) == [photo.id])

        try storage.deleteFromStorage(id: photo.id)
        #expect(try await first.next()?.isEmpty == true)
        #expect(try await second.next()?.isEmpty == true)
        #expect(try await third.next()?.isEmpty == true)
        #expect(try storage.getFavorites().isEmpty)
    }
}
