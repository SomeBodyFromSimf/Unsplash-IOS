import Data
import DITranquillity
import Domain
import catalog

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

        container.append(part: CatalogDI.self)
        container.register(main: { (catalogView: CatalogView) in
            MainContainer(catalogView: catalogView)
        })

        #if DEBUG
        assert(container.makeGraph().checkIsValid(), "Invalid application dependency graph")
        #endif

        return container
    }
}
