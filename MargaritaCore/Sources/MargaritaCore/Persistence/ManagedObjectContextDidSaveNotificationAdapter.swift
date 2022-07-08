//
//  ManagedObjectContextDidSaveNotificationAdapter.swift
//  
//
//  Created by Damjan on 27.06.2022.
//

import CoreData

struct ManagedObjectContextDidSaveNotificationAdapter {

    let notification: Notification

    var affectedObjectTypeIdentifiers: Set<ObjectIdentifier> {
        var affectedObjectTypeIdentifiers = Self.objectTypeIdentifiers(for: insertedObjects)
        affectedObjectTypeIdentifiers = affectedObjectTypeIdentifiers.union(Self.objectTypeIdentifiers(for: updatedObjects))
        affectedObjectTypeIdentifiers = affectedObjectTypeIdentifiers.union(Self.objectTypeIdentifiers(for: deletedObjects))
        return affectedObjectTypeIdentifiers
    }

    private static func objectTypeIdentifiers(for objects: Set<NSManagedObject>) -> Set<ObjectIdentifier> {
        objects.reduce(into: Set<ObjectIdentifier>()) { result, object in
            let objectTypeIdentifier = ObjectIdentifier(type(of: object))
            result.insert(objectTypeIdentifier)
        }
    }

    private var insertedObjects: Set<NSManagedObject> {
        notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
    }

    private var updatedObjects: Set<NSManagedObject> {
        notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
    }

    private var deletedObjects: Set<NSManagedObject> {
        notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []
    }
}
