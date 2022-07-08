//
//  ApiClient+Init.swift
//  
//
//  Created by Damjan on 29.06.2022.
//

import Combine
import Foundation

public extension ApiClient {

    convenience init(isInternetAvailable: AnyPublisher<Bool?, Never> = InternetMonitor.shared.isInternetAvailable) {
        let dataFromUrl = { (url: URL) -> AnyPublisher<Data, ApiClientError> in
            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .mapError { _ -> ApiClientError in
                    .unknown
                }
                .eraseToAnyPublisher()
        }
        self.init(isInternetAvailable: isInternetAvailable, dataFromUrl: dataFromUrl)
    }
}
