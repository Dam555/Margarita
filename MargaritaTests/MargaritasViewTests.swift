//
//  MargaritasViewTests.swift
//  MargaritaTests
//
//  Created by Damjan on 19.05.2022.
//

import Combine
@testable import Margarita
import MargaritaCore
import SnapshotTesting
import SwiftUI
import TestsCore
import XCTest

//
// Snapshots were created using `iPhone 12 mini`.
//
class MargaritasViewTests: BaseTestCase {

    func testMargaritasViewLoading() {
        let model = MargaritasModel(
            isIPad: false,
            margaritasFromApi: {
                PassthroughSubject<[Cocktail], ApiError>()
                    .eraseToAnyPublisher()
            }, saveMargaritas: { _ in
            }, margaritasFromStore: {
                []
            }, margaritaFromStore: { _ in
                MargaritaData(id: "", name: "", glass: "", instructions: "", imageUrl: URL.empty)
            }, purgeImages: { _ in
            }, downloadImage: { _, _ in
                Empty<UIImage, ImageDownloaderError>()
                    .eraseToAnyPublisher()
            }
        )
        let view = MargaritasView(model: model, isNavigationEnabled: false)
            .frame(width: 375, height: 500)
            .background(Color.white)

        assertSnapshot(matching: view.snapshotUIView(), as: .image)
    }

    func testMargaritasViewNoMargaritas() {
        let model = MargaritasModel(
            isIPad: false,
            margaritasFromApi: {
                Just([Cocktail]())
                    .setFailureType(to: ApiError.self)
                    .eraseToAnyPublisher()
            }, saveMargaritas: { _ in
            }, margaritasFromStore: {
                []
            }, margaritaFromStore: { _ in
                MargaritaData(id: "", name: "", glass: "", instructions: "", imageUrl: URL.empty)
            }, purgeImages: { _ in
            }, downloadImage: { _, _ in
                Empty<UIImage, ImageDownloaderError>()
                    .eraseToAnyPublisher()
            }
        )
        let view = MargaritasView(model: model, isNavigationEnabled: false)
            .frame(width: 375, height: 500)
            .background(Color.white)

        assertSnapshot(matching: view.snapshotUIView(), as: .image)
    }

    func testMargaritasView() throws {
        let model = MargaritasModel(
            isIPad: false,
            margaritasFromApi: {
                Fail<[Cocktail], ApiError>(error: .noInternet)
                    .eraseToAnyPublisher()
            }, saveMargaritas: { _ in
            }, margaritasFromStore: {
                [
                    MargaritaData(id: "1",
                                  name: "Margarita name 1",
                                  glass: "Margarita glass 1",
                                  instructions: "Margarita instructions 1",
                                  imageUrl: URL.empty),
                    MargaritaData(id: "2",
                                  name: "Margarita name 2",
                                  glass: "Margarita glass 2",
                                  instructions: "Margarita instructions 2",
                                  imageUrl: URL.empty),
                    MargaritaData(id: "3",
                                  name: "Margarita name 3",
                                  glass: "Margarita glass 3",
                                  instructions: "Margarita instructions 3",
                                  imageUrl: URL.empty),
                ]
            }, margaritaFromStore: { _ in
                MargaritaData(id: "", name: "", glass: "", instructions: "", imageUrl: URL.empty)
            }, purgeImages: { _ in
            }, downloadImage: { _, _ in
                Just(UIImage.margaritaSmall)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            }
        )
        let view = MargaritasView(model: model, isNavigationEnabled: false)
            .frame(width: 375, height: 500)
            .background(Color.white)

        assertSnapshot(matching: view.snapshotUIView(), as: .image)
    }
}
