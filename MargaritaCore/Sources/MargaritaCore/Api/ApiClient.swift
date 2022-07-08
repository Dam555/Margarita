//
//  ApiClient.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import Combine
import Foundation

public enum ApiClientError: Error {
    case noInternet
    case unknown
}

public class ApiClient {

    public let isInternetAvailable: AnyPublisher<Bool?, Never>
    public let dataFromUrl: (URL) -> AnyPublisher<Data, ApiClientError>

    public init(isInternetAvailable: AnyPublisher<Bool?, Never>,
                dataFromUrl: @escaping (URL) -> AnyPublisher<Data, ApiClientError>) {
        self.isInternetAvailable = isInternetAvailable
        self.dataFromUrl = dataFromUrl
    }

    public func data(from url: URL) -> AnyPublisher<Data, ApiClientError> {
        isInternetAvailable
            .compactMap { $0 }
            .tryFirst {
                guard $0 else { throw ApiClientError.noInternet }
                return true
            }
            .mapError { error -> ApiClientError in
                error as? ApiClientError ?? .unknown
            }
            .flatMap { _ -> AnyPublisher<Data, ApiClientError> in
                self.dataFromUrl(url)
            }
            .eraseToAnyPublisher()
    }
}
