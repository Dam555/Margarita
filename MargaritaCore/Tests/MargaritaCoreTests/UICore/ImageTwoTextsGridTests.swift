//
//  ImageTwoTextsGridTests.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

import Combine
@testable import MargaritaCore
import SnapshotTesting
import SwiftUI
import TestsCore
import XCTest

//
// Snapshots were created using `iPhone 12 mini`.
//
class ImageTwoTextsGridTests: BaseTestCase {

    func testImageTwoTextsGrid() {
        let grid = ImageTwoTextsGrid(
            imageUrl: .constant(URL.empty),
            topText: .constant("Top text"),
            bottomText: .constant("Bottom text"),
            downloadImage: { _, _ in
                Just(UIImage.margaritaSmall)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            }
        )
            .background(Color.white)

        assertSnapshot(matching: grid.snapshotUIView(), as: .image)
    }

    func testImageTwoTextsGridLoading() {
        let grid = ImageTwoTextsGrid(
            imageUrl: .constant(URL.empty),
            topText: .constant("Top text"),
            bottomText: .constant("Bottom text"),
            downloadImage: { _, _ in
                PassthroughSubject<UIImage, ImageDownloaderError>()
                    .eraseToAnyPublisher()
            }
        )
            .background(Color.white)

        assertSnapshot(matching: grid.snapshotUIView(), as: .image)
    }
}
