public import DITranquillity
import Domain

public final class FavoriteDI: DIPart {
    public static func load(container: DIContainer) {
        container.register(main: { (itemsStorage: any ItemsStorage) in
            FavoriteModel(itemsStorage: itemsStorage)
        })
            .lifetime(.prototype)
        container.register(main: { (model: FavoriteModel) in
            FavoriteView(model: model)
        })
    }
}
