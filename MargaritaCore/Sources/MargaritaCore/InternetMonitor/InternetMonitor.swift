//
//  InternetMonitor.swift
//  
//
//  Created by Damjan on 29.06.2022.
//

import Combine
import Foundation
import Network

public class InternetMonitor {

    public static let shared = InternetMonitor()

    private var internetMonitor: NWPathMonitor
    private let isInternetAvailableSubject = CurrentValueSubject<Bool?, Never>(nil)

    public init() {
        internetMonitor = NWPathMonitor()
        internetMonitor.pathUpdateHandler = { path in
            self.isInternetAvailableSubject.value = path.isAvailable
        }
        internetMonitor.start(queue: DispatchQueue.main)
    }

    public var isInternetAvailable: AnyPublisher<Bool?, Never> {
        return isInternetAvailableSubject
            .eraseToAnyPublisher()
    }
}
