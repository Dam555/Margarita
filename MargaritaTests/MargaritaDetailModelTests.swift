//
//  MargaritaDetailModelTests.swift
//  MargaritaTests
//
//  Created by Damjan on 02.07.2022.
//

import Combine
@testable import Margarita
import MargaritaCore
import TestsCore
import XCTest

class MargaritaDetailModelTests: BaseTestCase {

    class Mock {

        class Output {
            var margaritaFromStoreIds = [Identifier]()
        }

        let model: MargaritaDetailModel
        let output: Output

        init(margaritaId: String, margaritaFromStore: MargaritaData?, margaritaFromStoreError: StoreError?) {
            let output = Output()
            model = MargaritaDetailModel(
                margaritaId: margaritaId,
                margaritaFromStore: { id in
                    output.margaritaFromStoreIds.append(id)
                    if let error = margaritaFromStoreError {
                        throw error
                    } else if let margaritaFromStore = margaritaFromStore {
                        return margaritaFromStore
                    } else {
                        throw StoreError.objectNotFound
                    }
                },
                downloadImage: { _, _  in
                    // Not used in tests
                    PassthroughSubject<UIImage, ImageDownloaderError>()
                        .eraseToAnyPublisher()
                }
            )
            self.output = output
        }
    }

    func testMargaritaData() {
        let margaritaData = MargaritaData(id: "1",
                                          name: "Name",
                                          glass: "Glass",
                                          instructions: "Instructions",
                                          imageUrl: URL(string: "https://domain.com/image.jpeg")!)
        let mock = Mock(margaritaId: "1", margaritaFromStore: margaritaData, margaritaFromStoreError: nil)

        XCTAssertEqual(mock.output.margaritaFromStoreIds.count, 1)
        XCTAssertEqual(mock.output.margaritaFromStoreIds[0], "1")

        XCTAssertTrue(mock.model.margaritaExists)
        XCTAssertEqual(mock.model.name, margaritaData.name)
        XCTAssertEqual(mock.model.glass, margaritaData.glass)
        XCTAssertEqual(mock.model.instructions, margaritaData.instructions)
        XCTAssertEqual(mock.model.imageUrl, margaritaData.imageUrl)
    }

    func testMargaritaDataError() {
        let mock = Mock(margaritaId: "1", margaritaFromStore: nil, margaritaFromStoreError: StoreError.objectNotFound)

        XCTAssertEqual(mock.output.margaritaFromStoreIds.count, 1)
        XCTAssertEqual(mock.output.margaritaFromStoreIds[0], "1")

        XCTAssertFalse(mock.model.margaritaExists)
        XCTAssertTrue(mock.model.name.isEmpty)
        XCTAssertTrue(mock.model.glass.isEmpty)
        XCTAssertTrue(mock.model.instructions.isEmpty)
        XCTAssertEqual(mock.model.imageUrl, URL.empty)
    }
}
