//
//  MargaritaDetailModel.swift
//  Margarita
//
//  Created by Damjan on 24.05.2022.
//

import Combine
import CoreData
import MargaritaCore
import UIKit

class MargaritaDetailModel: ObservableObject {

    let downloadImage: (URL, ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>

    @Published var margaritaExists = false
    @Published var name = ""
    @Published var glass = ""
    @Published var instructions = ""
    @Published var imageUrl = URL.empty

    init(margaritaId: String,
         margaritaFromStore: @escaping (Identifier) throws -> MargaritaData,
         downloadImage: @escaping (URL, ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>) {
        self.downloadImage = downloadImage

        let margarita: MargaritaData
        do {
            margarita = try margaritaFromStore(margaritaId)
        } catch {
            return
        }

        name = margarita.name
        glass = margarita.glass
        instructions = margarita.instructions
        imageUrl = margarita.imageUrl
        margaritaExists = true
    }
}
