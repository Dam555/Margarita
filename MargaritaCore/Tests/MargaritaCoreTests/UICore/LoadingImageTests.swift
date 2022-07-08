//
//  LoadingImageTests.swift
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
class LoadingImageTests: BaseTestCase {

    func testLoadingImage() {
        let image = LoadingImage(
            url: .constant(URL.empty),
            size: .constant(.small),
            downloadImage: { _, _ in
                Just(UIImage.margaritaSmall)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            }
        )
            .frame(width: 44, height: 44)
            .background(Color.white)

        assertSnapshot(matching: image.snapshotUIView(), as: .image)
    }

    func testLoadingImageLoading() {
        let image = LoadingImage(
            url: .constant(URL.empty),
            size: .constant(.small),
            downloadImage: { _, _ in
                PassthroughSubject<UIImage, ImageDownloaderError>()
                    .eraseToAnyPublisher()
            }
        )
            .frame(width: 44, height: 44)
            .background(Color.white)

        assertSnapshot(matching: image.snapshotUIView(), as: .image)
    }
}
