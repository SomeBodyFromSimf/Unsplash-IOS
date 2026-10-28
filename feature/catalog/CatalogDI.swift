public import DITranquillity
import Domain

public final class CatalogDI: DIPart {
    public static func load(container: DIContainer) {
        container.register(main: { (photoApi: any PhotoApi, itemsStorage: any ItemsStorage) in
            CatalogModel(photoApi: photoApi, itemsStorage: itemsStorage)
        })
            .lifetime(.prototype)
        container.register(main: { (model: CatalogModel) in
            CatalogView(model: model)
        })
    }
}
