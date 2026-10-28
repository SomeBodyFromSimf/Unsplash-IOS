import Data
import SwiftData
import DITranquillity
import Domain
import catalog
import favorites

@MainActor
enum AppDI {
    static func makeContainer(accessKey: String) -> DIContainer {
        let container = DIContainer()

        container.register { URLSessionHTTPTransport() }
            .as(HTTPTransport.self)
            .lifetime(.single)
        container.register { (transport: any HTTPTransport) in
            APIClient(transport: transport)
        }
        .lifetime(.single)
        container.register { (client: APIClient) in
            UnsplashApi(apiClient: client, clientId: accessKey)
        }
        .as(PhotoApi.self)
        .lifetime(.single)
        container.register {
            let container: ModelContainer
            do {
                container = try ModelContainer(for: SwiftDataPhotoModel.self)
            } catch {
                fatalError("Не удалось создать SwiftData container: \(error)")
            }
            let context = ModelContext(container)
            
            return SwiftDataItemsStorage(context: context)
        }
        .as(ItemsStorage.self)
        .lifetime(.single)

        container.append(part: CatalogDI.self)
        container.append(part: FavoriteDI.self)
        container.register(main: { (catalogView: CatalogView, favoriteView: FavoriteView) in
            MainContainer(catalogView: catalogView, favoriteView: favoriteView)
        })

        #if DEBUG
        assert(container.makeGraph().checkIsValid(), "Invalid application dependency graph")
        #endif

        return container
    }
}
