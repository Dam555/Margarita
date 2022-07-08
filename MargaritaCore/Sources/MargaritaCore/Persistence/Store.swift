//
//  Store.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import CoreData

public enum StoreError: Error {
    case objectNotCreated
    case objectNotFound
    case fetchNotCreated
    case fetchFailed
    case changesNotSaved
}
public typealias Identifier = String

public class Store<ObjectType: NSManagedObject> {

    let objectContext: NSManagedObjectContext

    public init(objectContext: NSManagedObjectContext = Persistence.shared.makeObjectContext()) {
        self.objectContext = objectContext
    }

    public func addObject() -> ObjectType {
        ObjectType(context: objectContext)
    }

    public func deleteObject(_ object: ObjectType) {
        objectContext.delete(object)
    }

    public func makeFetchRequest() throws -> NSFetchRequest<ObjectType> {
        guard let entityName = ObjectType.entity().name else { throw StoreError.fetchNotCreated }
        return NSFetchRequest<ObjectType>(entityName: entityName)
    }

    public func executeFetchRequest(_ fetchRequest: NSFetchRequest<ObjectType>) throws -> [ObjectType] {
        let objects: [ObjectType]
        do {
            objects = try objectContext.fetch(fetchRequest)
        } catch {
            throw StoreError.fetchFailed
        }
        return objects
    }

    public func save() throws {
        guard objectContext.hasChanges else { return }
        do {
            try self.objectContext.save()
        }
        catch {
            throw StoreError.changesNotSaved
        }
    }
}
