//
//  Api.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import Combine
import Foundation

public enum ApiError: Error {
    case noInternet
    case invalidJson
    case unknown

    init(_ error: Error) {
        switch error {
        case let apiError as ApiError:
            self = apiError
        case let apiClientError as ApiClientError:
            switch apiClientError {
            case .noInternet: self = .noInternet
            default: self = .unknown
            }
        case is DecodingError:
            self = .invalidJson
        default: self = .unknown
        }
    }
}

public class Api {
    
    public let dataFromUrl: (URL) -> AnyPublisher<Data, ApiClientError>

    let margaritaCocktailsUrl = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=margarita")!

    public init(dataFromUrl: @escaping (URL) -> AnyPublisher<Data, ApiClientError>) {
        self.dataFromUrl = dataFromUrl
    }

    public func getMargaritaCocktails() -> AnyPublisher<[Cocktail], ApiError> {
        dataFromUrl(margaritaCocktailsUrl)
            .decode(type: Drinks.self, decoder: JSONDecoder())
            .map { $0.drinks }
            .mapError { ApiError($0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
