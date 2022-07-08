//
//  Persistence.swift
//  Margarita
//
//  Created by Damjan on 17.05.2022.
//

import CoreData
import UIKit

public struct Persistence {

    public static let shared = Persistence()
    public static let objectModelUrl = Bundle.module.url(forResource: "Margarita", withExtension: "momd")!

    private let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        guard !UIApplication.isRunningUnitTests else {
            fatalError("Cannot create app Persistence while running unit tests.")
        }
        let objectModel = NSManagedObjectModel(contentsOf: Self.objectModelUrl)!
        container = NSPersistentContainer(name: "Margarita", managedObjectModel: objectModel)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    public var imagesDirectoryUrl: URL = {
        do {
            let documentsDirectoryUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let imagesDirectoryUrl = documentsDirectoryUrl.appendingPathComponent("images", isDirectory: true)
            try FileManager.default.createDirectory(at: imagesDirectoryUrl, withIntermediateDirectories: true)
            return imagesDirectoryUrl
        } catch {
            fatalError("Images directory cannot be created.")
        }
    }()

    public func makeObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType) -> NSManagedObjectContext {
        let objectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        objectContext.persistentStoreCoordinator = container.persistentStoreCoordinator
        return objectContext
    }
}
