//
//  BaseTestCase.swift
//  
//
//  Created by Damjan on 29.06.2022.
//

import Combine
import CoreData
import MargaritaCore
import XCTest

open class BaseTestCase: XCTestCase {

    public func clearPersistence() throws {
        try tearDownPersistenceIfNeeded()
        try tearDownImagesDirectoryIfNeeded()
    }

    public var subscriptions = Set<AnyCancellable>()

    open override func tearDownWithError() throws {
        subscriptions.removeAll()
        try clearPersistence()
        try super.tearDownWithError()
    }

    //
    // Persistence (CoreDate)
    //

    private var isPersistenceSetUp = false

    // Object model must be loaded only once, otherwise there are errors with core data entities.
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let objectModelUrl = Persistence.objectModelUrl
        let objectModel = NSManagedObjectModel(contentsOf: objectModelUrl)!
        return NSPersistentStoreCoordinator(managedObjectModel: objectModel)
    }()

    private func setUpPersistenceIfNeeded() throws {
        guard !isPersistenceSetUp else { return }
        let storeUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("MockMargarita-\(UUID().uuidString).sqlite", isDirectory: false)
        try Self.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl)
        isPersistenceSetUp = true
    }

    private func tearDownPersistenceIfNeeded() throws {
        guard isPersistenceSetUp else { return }
        for store in Self.persistentStoreCoordinator.persistentStores {
            if let storeUrl = store.url {
                try Self.persistentStoreCoordinator.destroyPersistentStore(at: storeUrl, ofType: NSSQLiteStoreType, options: nil)
            }
        }
        isPersistenceSetUp = false
    }

    public func makeObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType) -> NSManagedObjectContext {
        do {
            try setUpPersistenceIfNeeded()
        } catch {
            fatalError("Persistence not set up.")
        }
        let objectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        objectContext.persistentStoreCoordinator = Self.persistentStoreCoordinator
        return objectContext
    }

    //
    // Persistence (Images directory)
    //

    private var imagesDirectoryUrlImpl: URL?

    private func setUpImagesDirectoryIfNeeded() throws {
        guard imagesDirectoryUrlImpl == nil else { return }
        let imagesDirectoryUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("MockImages-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: imagesDirectoryUrl, withIntermediateDirectories: true)
        imagesDirectoryUrlImpl = imagesDirectoryUrl
    }

    private func tearDownImagesDirectoryIfNeeded() throws {
        guard let imagesDirectoryUrl = imagesDirectoryUrlImpl else { return }
        if FileManager.default.fileExists(atPath: imagesDirectoryUrl.path) {
            try FileManager.default.removeItem(at: imagesDirectoryUrl)
        }
        imagesDirectoryUrlImpl = nil
    }

    public var imagesDirectoryUrl: URL {
        do {
            try setUpImagesDirectoryIfNeeded()
        } catch {
            fatalError("Images directory not set up.")
        }
        if let imagesDirectoryUrl = imagesDirectoryUrlImpl {
            return imagesDirectoryUrl
        } else {
            fatalError("Images directory not set up.")
        }
    }
}
