//
//  ManagedObjectContextDidSaveNotificationAdapterTests.swift
//  
//
//  Created by Damjan on 02.07.2022.
//

import CoreData
@testable import MargaritaCore
import TestsCore
import XCTest

class ManagedObjectContextDidSaveNotificationAdapterTests: BaseTestCase {

    func testAffectedObjectTypeIdentifiersInserted() {
        let objectContext = makeObjectContext()
        let insertedNotification = Notification(
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil,
            userInfo: [NSInsertedObjectsKey: Set<NSManagedObject>([Image(context: objectContext)])]
        )
        let adapter = ManagedObjectContextDidSaveNotificationAdapter(notification: insertedNotification)
        XCTAssertEqual(adapter.affectedObjectTypeIdentifiers, Set<ObjectIdentifier>([ObjectIdentifier(Image.self)]))
    }

    func testAffectedObjectTypeIdentifiersUpdated() {
        let objectContext = makeObjectContext()
        let updatedNotification = Notification(
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil,
            userInfo: [NSUpdatedObjectsKey: Set<NSManagedObject>([Image(context: objectContext)])]
        )
        let adapter = ManagedObjectContextDidSaveNotificationAdapter(notification: updatedNotification)
        XCTAssertEqual(adapter.affectedObjectTypeIdentifiers, Set<ObjectIdentifier>([ObjectIdentifier(Image.self)]))
    }

    func testAffectedObjectTypeIdentifiersDeleted() {
        let objectContext = makeObjectContext()
        let deletedNotification = Notification(
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil,
            userInfo: [NSDeletedObjectsKey: Set<NSManagedObject>([Image(context: objectContext)])]
        )
        let adapter = ManagedObjectContextDidSaveNotificationAdapter(notification: deletedNotification)
        XCTAssertEqual(adapter.affectedObjectTypeIdentifiers, Set<ObjectIdentifier>([ObjectIdentifier(Image.self)]))
    }

    func testAffectedObjectTypeIdentifiers() {
        let objectContext = makeObjectContext()
        let notification = Notification(
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil,
            userInfo: [
                NSInsertedObjectsKey: Set<NSManagedObject>([Image(context: objectContext)]),
                NSUpdatedObjectsKey: Set<NSManagedObject>([Image(context: objectContext)]),
                NSDeletedObjectsKey: Set<NSManagedObject>([Margarita(context: objectContext)]),

            ]
        )
        let adapter = ManagedObjectContextDidSaveNotificationAdapter(notification: notification)
        XCTAssertEqual(adapter.affectedObjectTypeIdentifiers,
                       Set<ObjectIdentifier>([ObjectIdentifier(Image.self), ObjectIdentifier(Margarita.self)]))
    }
}
