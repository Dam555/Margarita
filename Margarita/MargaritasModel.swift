//
//  MargaritasModel.swift
//  Margarita
//
//  Created by Damjan on 17.05.2022.
//

import Combine
import Foundation
import MargaritaCore
import UIKit

class MargaritasModel: ObservableObject {

    enum DisplayError: Error {
        case noInternet
        case apiError
        case unknown

        init(_ error: Error) {
            switch error {
            case let displayError as DisplayError:
                self = displayError
            case let apiError as ApiError:
                switch apiError {
                case .noInternet: self = .noInternet
                default: self = .apiError
                }
            default: self = .unknown
            }
        }
    }

    enum PresentedAlert {
        case none
        case noInternet
        case apiError
        case unknownError
    }

    let isIPad: Bool
    let downloadImage: (URL, ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>
    let margaritaFromStore: (Identifier) throws -> MargaritaData
    
    @Published var isLoading = true
    @Published var margaritas = [MargaritaData]()
    @Published var presentedAlert = PresentedAlert.none

    init(isIPad: Bool,
         margaritasFromApi: () -> AnyPublisher<[Cocktail], ApiError>,
         saveMargaritas: @escaping ([Cocktail]) throws -> Void,
         margaritasFromStore: @escaping () throws -> [MargaritaData],
         margaritaFromStore: @escaping (Identifier) throws -> MargaritaData,
         purgeImages: @escaping ([KeepImageUrl]) throws -> Void,
         downloadImage: @escaping (URL, ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>) {
        self.isIPad = isIPad
        self.margaritaFromStore = margaritaFromStore
        self.downloadImage = downloadImage

        var subscription: AnyCancellable?
        subscription = margaritasFromApi()
            .tryMap { cocktails -> [MargaritaData] in
                try saveMargaritas(cocktails)
                try purgeImages(cocktails.map { $0.imageUrl })
                return try margaritasFromStore()
            }
            .tryCatch { error -> AnyPublisher<[MargaritaData], Error> in
                self.presentAlert(for: error)
                return Just(try margaritasFromStore())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.presentAlert(for: error)
                }
                subscription?.cancel()
            } receiveValue: { [weak self] margaritas in
                self?.margaritas = margaritas
            }
    }
}

private extension MargaritasModel {

    func presentAlert(for error: Error) {
        switch DisplayError(error) {
        case .noInternet: presentedAlert = .noInternet
        case .apiError: presentedAlert = .apiError
        case .unknown: presentedAlert = .unknownError
        }
    }
}
