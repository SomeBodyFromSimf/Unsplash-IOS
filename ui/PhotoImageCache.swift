internal import Kingfisher

@MainActor
enum PhotoImageCache {
    static let shared: ImageCache = {
        // Сохраняем стандартный кеш, чтобы использовать уже загруженные фото.
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 64 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 300 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(30)
        return cache
    }()
}
