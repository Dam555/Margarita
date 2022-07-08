//
//  MargaritaDetailViewTests.swift
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
class MargaritaDetailViewTests: BaseTestCase {

    func testMargaritaDetailViewNoMargarita() throws {
        let model = MargaritaDetailModel(
            margaritaId: "",
            margaritaFromStore: { _ in
                throw StoreError.objectNotFound
            },
            downloadImage: { _, _ in
                Empty<UIImage, ImageDownloaderError>()
                    .eraseToAnyPublisher()
            }
        )
        let view = MargaritaDetailView(model: model)
            .frame(width: 375, height: 500)
            .background(Color.white)

        assertSnapshot(matching: view.snapshotUIView(), as: .image)
    }

    func testMargaritaDetailView() throws {
        let model = MargaritaDetailModel(
            margaritaId: "",
            margaritaFromStore: { _ in
                MargaritaData(id: "1",
                              name: "Margarita name",
                              glass: "Margarita glass",
                              instructions: "Margarita instructions some very long instructions for two lines.",
                              imageUrl: URL.empty)
            },
            downloadImage: { _, _ in
                Just(UIImage.margaritaLarge)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            }
        )
        let view = MargaritaDetailView(model: model)
            .frame(width: 375, height: 500)
            .background(Color.white)

        assertSnapshot(matching: view.snapshotUIView(), as: .image)
    }
}
