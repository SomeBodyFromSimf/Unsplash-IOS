//
//  CoreDataItemsStorage.swift
//  StudyProject
//
//  Created by Чистоусов Михаил on 07.09.2026.
//
import SwiftData
import Foundation
import Domain

@MainActor
public final class SwiftDataItemsStorage: ItemsStorage {
    
    private let context: ModelContext
    private var observers: [UUID: AsyncThrowingStream<[PhotoModel], Error>.Continuation] = [:]
    
    public init(context: ModelContext) {
        self.context = context
    }

    public func observeFavorites() -> AsyncThrowingStream<[PhotoModel], Error> {
        let id = UUID()
        let (stream, continuation) = AsyncThrowingStream<[PhotoModel], Error>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.observers.removeValue(forKey: id)
            }
        }

        do {
            let photos = try getFavorites()
            observers[id] = continuation
            continuation.yield(photos)
        } catch {
            continuation.finish(throwing: error)
        }
        return stream
    }
    
    public func getFavorites() throws -> [PhotoModel] {
        let descriptor = FetchDescriptor<SwiftDataPhotoModel>(
            sortBy: [ SortDescriptor(\.addedAt, order: .reverse) ]
        )

        let records = try context.fetch(descriptor)

        return records.map { record in
            PhotoModel(from: record)
        }
    }
    
    public func getFavoriteIds() throws -> [String] {
        let descriptor = FetchDescriptor<SwiftDataPhotoModel>()

        let records = try context.fetch(descriptor)

        return records.map { record in
            record.id
        }
    }
    
    public func addIntoStorage(model: PhotoModel) throws {
        let record = SwiftDataPhotoModel(from: model)
        context.insert(record)
        try saveAndNotify()
    }
    
    public func deleteFromStorage(id: String) throws {
        let descriptor = FetchDescriptor<SwiftDataPhotoModel>(
            predicate: #Predicate { $0.id == id }
        )
        
        guard let record = try context.fetch(descriptor).first else {
            throw SwiftDataItemsStorageError.recordNotFound(id)
        }
        
        context.delete(record)
        try saveAndNotify()
    }

    private func saveAndNotify() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }

        do {
            let photos = try getFavorites()
            for continuation in observers.values {
                continuation.yield(photos)
            }
        } catch {
            // Запись уже сохранена; ошибка чтения относится к наблюдению.
            for continuation in observers.values {
                continuation.finish(throwing: error)
            }
            observers.removeAll()
        }
    }

    deinit {
        for continuation in observers.values {
            continuation.finish()
        }
    }
}

enum SwiftDataItemsStorageError: Error {
    case recordNotFound(String)
}
