//
//  MargaritasModelTests.swift
//  MargaritaTests
//
//  Created by Damjan on 18.05.2022.
//

import Combine
@testable import Margarita
import MargaritaCore
import TestsCore
import XCTest

class MargaritasModelTests: BaseTestCase {

    class Mock {

        class Output {
            var margaritasFromApiCount: Int = 0
            var savedMargaritas = [[Cocktail]]()
            var margaritasFromStoreCount: Int = 0
            var purgeImageUrls = [[KeepImageUrl]]()
        }

        let model: MargaritasModel
        let margaritasFromApiSubject: PassthroughSubject<[Cocktail], ApiError>
        let output: Output

        init(margaritasFromStore: [MargaritaData]) {
            let margaritasFromApiSubject = PassthroughSubject<[Cocktail], ApiError>()
            let output = Output()
            model = MargaritasModel(
                isIPad: false,
                margaritasFromApi: {
                    output.margaritasFromApiCount += 1
                    return margaritasFromApiSubject
                        .eraseToAnyPublisher()
                },
                saveMargaritas: { cocktails in
                    output.savedMargaritas.append(cocktails)
                },
                margaritasFromStore: {
                    output.margaritasFromStoreCount += 1
                    return margaritasFromStore
                },
                margaritaFromStore: { _ in
                    // Not used in tests
                    throw StoreError.objectNotFound
                },
                purgeImages: { keepImageUrls in
                    output.purgeImageUrls.append(keepImageUrls)
                },
                downloadImage: { _, _ in
                    // Not used in tests
                    PassthroughSubject<UIImage, ImageDownloaderError>()
                        .eraseToAnyPublisher()
                }
            )
            self.margaritasFromApiSubject = margaritasFromApiSubject
            self.output = output
        }
    }

    func testWaitingForInternetAvailability() {
        let mock = Mock(margaritasFromStore: [])

        XCTAssertEqual(mock.output.margaritasFromApiCount, 1)
        XCTAssertTrue(mock.output.savedMargaritas.isEmpty)
        XCTAssertEqual(mock.output.margaritasFromStoreCount, 0)
        XCTAssertTrue(mock.output.purgeImageUrls.isEmpty)

        XCTAssertTrue(mock.model.isLoading)
        XCTAssertTrue(mock.model.margaritas.isEmpty)
        XCTAssertEqual(mock.model.presentedAlert, .none)
    }

    func testInternetNotAvailableNoData() {
        let mock = Mock(margaritasFromStore: [])

        mock.margaritasFromApiSubject.send(completion: .failure(.noInternet))

        XCTAssertEqual(mock.output.margaritasFromApiCount, 1)
        XCTAssertTrue(mock.output.savedMargaritas.isEmpty)
        XCTAssertEqual(mock.output.margaritasFromStoreCount, 1)
        XCTAssertTrue(mock.output.purgeImageUrls.isEmpty)

        XCTAssertFalse(mock.model.isLoading)
        XCTAssertTrue(mock.model.margaritas.isEmpty)
        XCTAssertEqual(mock.model.presentedAlert, .noInternet)
    }

    func testInternetNotAvailableOldData() throws {
        let mock = Mock(
            margaritasFromStore: [
                MargaritaData(id: "1",
                              name: "Name",
                              glass: "Glass",
                              instructions: "Instructions",
                              imageUrl: URL.empty)
            ]
        )

        mock.margaritasFromApiSubject.send(completion: .failure(.noInternet))

        XCTAssertEqual(mock.output.margaritasFromApiCount, 1)
        XCTAssertTrue(mock.output.savedMargaritas.isEmpty)
        XCTAssertEqual(mock.output.margaritasFromStoreCount, 1)
        XCTAssertTrue(mock.output.purgeImageUrls.isEmpty)

        XCTAssertFalse(mock.model.isLoading)
        XCTAssertEqual(mock.model.margaritas.count, 1)
        XCTAssertEqual(mock.model.margaritas[0].id, "1")
        XCTAssertEqual(mock.model.margaritas[0].name, "Name")
        XCTAssertEqual(mock.model.margaritas[0].glass, "Glass")
        XCTAssertEqual(mock.model.margaritas[0].imageUrl, URL.empty)
        XCTAssertEqual(mock.model.presentedAlert, .noInternet)
    }

    func testApiErrorNoData() {
        let mock = Mock(margaritasFromStore: [])

        mock.margaritasFromApiSubject.send(completion: .failure(.unknown))

        XCTAssertEqual(mock.output.margaritasFromApiCount, 1)
        XCTAssertTrue(mock.output.savedMargaritas.isEmpty)
        XCTAssertEqual(mock.output.margaritasFromStoreCount, 1)
        XCTAssertTrue(mock.output.purgeImageUrls.isEmpty)

        XCTAssertFalse(mock.model.isLoading)
        XCTAssertTrue(mock.model.margaritas.isEmpty)
        XCTAssertEqual(mock.model.presentedAlert, .apiError)
    }

    func testApi() throws {
        let mock = Mock(
            margaritasFromStore: [
                MargaritaData(id: "1",
                              name: "Name",
                              glass: "Glass",
                              instructions: "Instructions",
                              imageUrl: URL.empty)
            ]
        )

        let cocktail = Cocktail(id: "1",
                                name: "Name",
                                glass: "Glass",
                                instructions: "Instructions",
                                imageUrl: URL.empty)
        mock.margaritasFromApiSubject.send([cocktail])
        mock.margaritasFromApiSubject.send(completion: .finished)

        XCTAssertEqual(mock.output.margaritasFromApiCount, 1)
        XCTAssertEqual(mock.output.savedMargaritas.count, 1)
        XCTAssertEqual(mock.output.savedMargaritas[0], [cocktail])
        XCTAssertEqual(mock.output.margaritasFromStoreCount, 1)
        XCTAssertEqual(mock.output.purgeImageUrls.count, 1)
        XCTAssertEqual(mock.output.purgeImageUrls[0], [URL.empty])

        XCTAssertFalse(mock.model.isLoading)
        XCTAssertEqual(mock.model.margaritas.count, 1)
        XCTAssertEqual(mock.model.margaritas[0].id, "1")
        XCTAssertEqual(mock.model.margaritas[0].name, "Name")
        XCTAssertEqual(mock.model.margaritas[0].glass, "Glass")
        XCTAssertEqual(mock.model.margaritas[0].imageUrl, URL.empty)
        XCTAssertEqual(mock.model.presentedAlert, .none)
    }
}
