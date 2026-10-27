public import DITranquillity
import Domain

public final class CatalogDI: DIPart {
    public static func load(container: DIContainer) {
        container.register(main: { (photoApi: any PhotoApi) in
            CatalogModel(photoApi: photoApi)
        })
            .lifetime(.prototype)
        container.register(main: { (model: CatalogModel) in
            CatalogView(model: model)
        })
    }
}
