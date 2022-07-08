//
//  ImageDownloader.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import Combine
import UIKit

public enum ImageDownloaderError: Error {
    case invalidImageData
    case unknown
}

public typealias SmallImageData = Data
public typealias LargeImageData = Data

public class ImageDownloader {

    private struct DownloadedImage {

        enum State {
            case success(_ smallImage: UIImage, _ largeImage: UIImage)
            case error(ImageDownloaderError)
        }

        let url: URL
        let state: State
    }

    let imageData: (URL) -> AnyPublisher<Data, ApiClientError>
    let cachedImageData: (URL, ImageStoreImageSize) throws -> Data?
    let updateCachedImage: (URL, SmallImageData, LargeImageData) throws -> Void

    public static let smallImageMinDimension: CGFloat = 44
    public static let largeImageWidth: CGFloat = 640

    private var downloadingUrls = Set<URL>()
    private var smallImageInMemoryCache = NSCache<NSURL, UIImage>()
    private let downloadedImageSubject = PassthroughSubject<DownloadedImage, Never>()

    public init(imageData: @escaping (URL) -> AnyPublisher<Data, ApiClientError>,
                cachedImageData: @escaping (URL, ImageStoreImageSize) throws -> Data?,
                updateCachedImage: @escaping (URL, SmallImageData, LargeImageData) throws -> Void) {
        self.imageData = imageData
        self.cachedImageData = cachedImageData
        self.updateCachedImage = updateCachedImage
    }

    public func image(from url: URL, size: ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError> {
        if case .small = size, let image = smallImageInMemoryCache.object(forKey: url as NSURL) {
            // Return small image from memory cache if exists.
            return Just<UIImage>(image)
                .setFailureType(to: ImageDownloaderError.self)
                .eraseToAnyPublisher()
        } else if let imageFromStore = self.imageFromStore(for: url, size: size) {
            // Return image from store if exists.
            return imageFromStore
        } else {
            // Download image
            return downloadImage(from: url, receiveSize: size)
        }
    }
}

private extension ImageDownloader {

    func imageFromStore(for url: URL, size: ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>? {
        do {
            guard let imageData = try cachedImageData(url, size) else { return nil }

            if let image = UIImage(data: imageData, scale: UIScreen.main.scale) {
                if case .small = size {
                    smallImageInMemoryCache.setObject(image, forKey: url as NSURL)
                }
                return Just<UIImage>(image)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail<UIImage, ImageDownloaderError>(error: .invalidImageData)
                    .eraseToAnyPublisher()
            }
        } catch {
            return Fail<UIImage, ImageDownloaderError>(error: .unknown)
                .eraseToAnyPublisher()
        }
    }

    func downloadImage(from url: URL, receiveSize: ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError> {

        // Subscribe to `downloadedImageSubject` to receive image once it gets downloaded.
        let receivePublisher = receiveDownloadedImage(from: url, receiveSize: receiveSize)

        // Check if downloading from `url` is already in progress.
        guard !downloadingUrls.contains(url) else { return receivePublisher }
        downloadingUrls.insert(url)

        // Download image and once downloaded, publish it via `downloadedImageSubject`.
        var subscription: AnyCancellable?
        subscription = imageData(url)
            .tryMap { originalImageData -> (smallImageJpegData: Data, largeImageJpegData: Data) in
                try self.smallAndLargeImageData(fromOriginalImageData: originalImageData)
            }
            .receive(on: DispatchQueue.main)
            .tryMap { imagesData -> (smallImage: UIImage, largeImage: UIImage) in
                do {
                    try self.updateCachedImage(url, imagesData.smallImageJpegData, imagesData.largeImageJpegData)
                } catch {
                    throw ImageDownloaderError.unknown
                }
                return try (self.image(fromImageData: imagesData.smallImageJpegData), self.image(fromImageData: imagesData.largeImageJpegData))
            }
            .mapError { error -> ImageDownloaderError in
                error as? ImageDownloaderError ?? .unknown
            }
            .sink { completion in
                if case .failure(let error) = completion {
                    let downloadedImage = DownloadedImage(url: url, state: .error(error))
                    self.downloadedImageSubject.send(downloadedImage)
                }
                self.downloadingUrls.remove(url)
                subscription?.cancel()
            } receiveValue: { images in
                let downloadedImage = DownloadedImage(url: url, state: .success(images.smallImage, images.largeImage))
                self.downloadedImageSubject.send(downloadedImage)
            }

        return receivePublisher
    }

    // Receive downloaded image published from `downloadedImageSubject` once it gets downloaded.
    func receiveDownloadedImage(from url: URL, receiveSize: ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError> {
        downloadedImageSubject
            .filter { $0.url == url }
            .first()
            .tryMap { downloadedImage in
                switch downloadedImage.state {
                case .success(let smallImage, let largeImage):
                    switch receiveSize {
                    case .small: return smallImage
                    case .large: return largeImage
                    }
                case .error(let error):
                    throw error
                }
            }
            .mapError { error -> ImageDownloaderError in
                error as? ImageDownloaderError ?? .unknown
            }
            .eraseToAnyPublisher()
    }

    func smallAndLargeImageData(fromOriginalImageData originalImageData: Data) throws -> (smallImageJpegData: Data, largeImageJpegData: Data) {
        guard let originalImage = UIImage(data: originalImageData) else {
            throw ImageDownloaderError.invalidImageData
        }

        let smallImageSize: CGSize
        if originalImage.size.width > originalImage.size.height {
            let imageHeight = min(Self.smallImageMinDimension, originalImage.size.height)
            smallImageSize = CGSize(width: (originalImage.size.width / originalImage.size.height) * imageHeight, height: imageHeight)
        } else {
            let imageWidth = min(Self.smallImageMinDimension, originalImage.size.width)
            smallImageSize = CGSize(width: imageWidth, height: (originalImage.size.height / originalImage.size.width) * imageWidth)
        }
        let smallImageRenderer = UIGraphicsImageRenderer(size: smallImageSize, format: UIGraphicsImageRendererFormat())
        let smallImageJpegData = smallImageRenderer.jpegData(withCompressionQuality: 1) { _ in
            originalImage.draw(in: CGRect(origin: .zero, size: smallImageSize))
        }

        let largeImageSize = CGSize(width: Self.largeImageWidth, height: (originalImage.size.height / originalImage.size.width) * Self.largeImageWidth)
        let largeImageRenderer = UIGraphicsImageRenderer(size: largeImageSize, format: UIGraphicsImageRendererFormat())
        let largeImageJpegData = largeImageRenderer.jpegData(withCompressionQuality: 1) { _ in
            originalImage.draw(in: CGRect(origin: .zero, size: largeImageSize))
        }

        return (smallImageJpegData, largeImageJpegData)
    }

    func image(fromImageData imageData: Data) throws -> UIImage {
        guard let image = UIImage(data: imageData, scale: UIScreen.main.scale) else {
            throw ImageDownloaderError.invalidImageData
        }
        return image
    }
}
