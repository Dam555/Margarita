//
//  ImageDownloaderTests.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

import Combine
@testable import MargaritaCore
import TestsCore
import XCTest

class ImageDownloaderTests: BaseTestCase {

    class Mock {

        struct CachedImage: Hashable {
            let url: URL
            let size: ImageStoreImageSize
        }

        struct UpdatedImage: Hashable {
            let url: URL
            let smallImageData: SmallImageData
            let largeImageData: LargeImageData
        }

        class Output {
            var imageDataUrls = [URL]()
            var cachedImages = [CachedImage]()
            var updatedImages = [UpdatedImage]()
        }

        let imageDownloader: ImageDownloader
        let imageDataSubject: PassthroughSubject<Data, ApiClientError>
        let output: Output

        init(cachedImageData: [CachedImage: Data]?, cachedImageDataError: StoreError?, updateCachedImageError: StoreError?) {
            let imageDataSubject = PassthroughSubject<Data, ApiClientError>()
            let output = Output()
            imageDownloader = ImageDownloader(
                imageData: { url in
                    output.imageDataUrls.append(url)
                    return imageDataSubject
                        .eraseToAnyPublisher()
                },
                cachedImageData: { url, imageSize in
                    let cachedImage = CachedImage(url: url, size: imageSize)
                    output.cachedImages.append(cachedImage)
                    if let error = cachedImageDataError {
                        throw error
                    } else if let cachedImageData = cachedImageData {
                        return cachedImageData[cachedImage]
                    } else {
                        throw StoreError.objectNotFound
                    }
                },
                updateCachedImage: { url, smallImageData, largeImageData in
                    let updatedImage = UpdatedImage(url: url, smallImageData: smallImageData, largeImageData: largeImageData)
                    output.updatedImages.append(updatedImage)
                    if let error = updateCachedImageError {
                        throw error
                    }
                }
            )
            self.imageDataSubject = imageDataSubject
            self.output = output
        }
    }

    func testImageFromStore() throws {
        let margaritaSmallJpegData = try XCTUnwrap(UIImage.margaritaSmall.jpegData(compressionQuality: 1))
        let mock = Mock(cachedImageData: [Mock.CachedImage(url: URL.empty, size: .small): margaritaSmallJpegData], cachedImageDataError: nil, updateCachedImageError: nil)

        let imageExpectation = expectation(description: "")
        let completionExpectation = expectation(description: "")

        mock.imageDownloader.image(from: URL.empty, size: .small)
            .sink { completion in
                XCTAssertEqual(completion, .finished)
                completionExpectation.fulfill()
            } receiveValue: { image in
                imageExpectation.fulfill()
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)
    }

    func testImageFromStoreError() throws {
        let mock = Mock(cachedImageData: nil, cachedImageDataError: .objectNotFound, updateCachedImageError: nil)

        let imageExpectation = expectation(description: "")
        imageExpectation.isInverted = true
        let failureExpectation = expectation(description: "")

        mock.imageDownloader.image(from: URL.empty, size: .small)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, .unknown)
                    failureExpectation.fulfill()
                case .finished:
                    XCTFail("Shouldn't have finished normally")
                }
            } receiveValue: { image in
                imageExpectation.fulfill()
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)
    }

    func testImageFromMemoryCache() throws {
        let margaritaSmallJpegData = try XCTUnwrap(UIImage.margaritaSmall.jpegData(compressionQuality: 1))
        let mock = Mock(cachedImageData: [Mock.CachedImage(url: URL.empty, size: .small): margaritaSmallJpegData], cachedImageDataError: nil, updateCachedImageError: nil)

        let imageExpectation = expectation(description: "")
        let completionExpectation = expectation(description: "")

        mock.imageDownloader.image(from: URL.empty, size: .small)
            .sink { completion in
                XCTAssertEqual(completion, .finished)
                completionExpectation.fulfill()
            } receiveValue: { image in
                XCTAssertTrue(mock.output.imageDataUrls.isEmpty)
                XCTAssertEqual(mock.output.cachedImages.count, 1)
                XCTAssertTrue(mock.output.updatedImages.isEmpty)
                imageExpectation.fulfill()
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)

        let imageExpectation2 = expectation(description: "")
        let completionExpectation2 = expectation(description: "")

        mock.imageDownloader.image(from: URL.empty, size: .small)
            .sink { completion in
                XCTAssertEqual(completion, .finished)
                completionExpectation2.fulfill()
            } receiveValue: { image in
                XCTAssertTrue(mock.output.imageDataUrls.isEmpty)
                XCTAssertEqual(mock.output.cachedImages.count, 1)
                XCTAssertTrue(mock.output.updatedImages.isEmpty)
                imageExpectation2.fulfill()
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)
    }

    func testImageFromUrl() throws {
        let mock = Mock(cachedImageData: [:], cachedImageDataError: nil, updateCachedImageError: nil)

        let imageExpectation = expectation(description: "")
        let completionExpectation = expectation(description: "")

        mock.imageDownloader.image(from: URL.empty, size: .small)
            .sink { completion in
                XCTAssertEqual(completion, .finished)
                completionExpectation.fulfill()
            } receiveValue: { image in
                XCTAssertEqual(mock.output.imageDataUrls.count, 1)
                XCTAssertEqual(mock.output.imageDataUrls[0], URL.empty)
                XCTAssertEqual(mock.output.cachedImages.count, 1)
                XCTAssertEqual(mock.output.updatedImages.count, 1)
                XCTAssertEqual(mock.output.updatedImages[0].url, URL.empty)
                imageExpectation.fulfill()
            }
            .store(in: &subscriptions)

        let margaritaJpegData = try XCTUnwrap(UIImage.margaritaLarge.jpegData(compressionQuality: 1))
        mock.imageDataSubject.send(margaritaJpegData)
        mock.imageDataSubject.send(completion: .finished)

        waitForExpectations(timeout: 0.25)
    }

    func testImageFromUrlError() throws {
        let mock = Mock(cachedImageData: [:], cachedImageDataError: nil, updateCachedImageError: nil)

        let imageExpectation = expectation(description: "")
        imageExpectation.isInverted = true
        let failureExpectation = expectation(description: "")

        mock.imageDownloader.image(from: URL.empty, size: .small)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, .unknown)
                    XCTAssertEqual(mock.output.imageDataUrls.count, 1)
                    XCTAssertEqual(mock.output.imageDataUrls[0], URL.empty)
                    XCTAssertEqual(mock.output.cachedImages.count, 1)
                    XCTAssertTrue(mock.output.updatedImages.isEmpty)
                    failureExpectation.fulfill()
                case .finished:
                    XCTFail("Shouldn't have finished normally")
                }
            } receiveValue: { image in
                imageExpectation.fulfill()
            }
            .store(in: &subscriptions)

        mock.imageDataSubject.send(completion: .failure(.unknown))

        waitForExpectations(timeout: 0.25)
    }
}
