//
//  StoreObserverTests.swift
//  
//
//  Created by Damjan on 02.07.2022.
//

import CoreData
@testable import MargaritaCore
import TestsCore
import XCTest

class StoreObserverTests: BaseTestCase {

    func testStoreDidChange() {
        let objectContext = makeObjectContext()

        let changeExpectation = expectation(description: "")
        let completionExpectation = expectation(description: "")
        completionExpectation.isInverted = true

        let storeObserver = StoreObserver()
        storeObserver.storeDidChange(for: Image.self)
            .sink { _ in
                completionExpectation.fulfill()
            } receiveValue: {
                changeExpectation.fulfill()
            }
            .store(in: &subscriptions)

        let notification = Notification(
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil,
            userInfo: [NSInsertedObjectsKey: Set<NSManagedObject>([Image(context: objectContext)])]
        )
        NotificationCenter.default.post(notification)

        waitForExpectations(timeout: 0.25)
    }

    func testStoreDidNotChange() {
        let objectContext = makeObjectContext()

        let changeExpectation = expectation(description: "")
        changeExpectation.isInverted = true
        let completionExpectation = expectation(description: "")
        completionExpectation.isInverted = true

        let storeObserver = StoreObserver()
        storeObserver.storeDidChange(for: Margarita.self)
            .sink { _ in
                completionExpectation.fulfill()
            } receiveValue: {
                changeExpectation.fulfill()
            }
            .store(in: &subscriptions)

        let notification = Notification(
            name: Notification.Name.NSManagedObjectContextDidSave,
            object: nil,
            userInfo: [NSInsertedObjectsKey: Set<NSManagedObject>([Image(context: objectContext)])]
        )
        NotificationCenter.default.post(notification)

        waitForExpectations(timeout: 0.25)
    }
}
