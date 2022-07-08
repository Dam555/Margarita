//
//  StoreObserver.swift
//  
//
//  Created by Damjan on 27.06.2022.
//

import Combine
import CoreData
import Foundation

public class StoreObserver {

    private var managedObjectContextDidSaveSubscription: AnyCancellable?
    private var storeDidChangeSubjects = [ObjectIdentifier: PassthroughSubject<Void, Never>]()

    init() {
        managedObjectContextDidSaveSubscription = NotificationCenter.default.publisher(for: Notification.Name.NSManagedObjectContextDidSave)
            .map { notification -> Set<ObjectIdentifier> in
                let adapter = ManagedObjectContextDidSaveNotificationAdapter(notification: notification)
                return adapter.affectedObjectTypeIdentifiers
            }
            .sink { [weak self] objectTypeIdentifiers in
                let sendChangeEvents = {
                    for objectTypeIdentifier in objectTypeIdentifiers {
                        self?.storeDidChangeSubjects[objectTypeIdentifier]?.send()
                    }
                }
                if Thread.isMainThread {
                    sendChangeEvents()
                } else {
                    DispatchQueue.main.sync {
                        sendChangeEvents()
                    }
                }
            }
    }

    // Store change events are delivered on main thread.
    public func storeDidChange<T: NSManagedObject>(for objectType: T.Type) -> AnyPublisher<Void, Never> {
        let storeObjectTypeIdentifier = ObjectIdentifier(objectType)
        var storeDidChangeSubject = PassthroughSubject<Void, Never>()
        let setUpSubject = {
            if let subject = self.storeDidChangeSubjects[storeObjectTypeIdentifier] {
                storeDidChangeSubject = subject
            } else {
                self.storeDidChangeSubjects[storeObjectTypeIdentifier] = storeDidChangeSubject
            }
        }
        if Thread.isMainThread {
            setUpSubject()
        } else {
            DispatchQueue.main.sync {
                setUpSubject()
            }
        }
        return storeDidChangeSubject
            .eraseToAnyPublisher()
    }
}
