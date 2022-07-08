//
//  SwiftUIView.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import Combine
import SwiftUI

public struct LoadingImage: View {

    @Binding var url: URL
    @Binding var size: ImageStoreImageSize
    let downloadImage: (URL, ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>

    @State private var image: UIImage?

    public init(url: Binding<URL>,
                size: Binding<ImageStoreImageSize>,
                downloadImage: @escaping (URL, ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>) {
        self._url = url
        self._size = size
        self.downloadImage = downloadImage
    }

    public var body: some View {
        Group {
            if let image = image {
                SwiftUI.Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            self.downloadImageIfNeeded()
        }
    }

    func downloadImageIfNeeded() {
        guard image == nil else { return }
        var subscription: AnyCancellable?
        subscription = downloadImage(url, size)
            .sink { _ in
                subscription?.cancel()
            } receiveValue: { image in
                self.image = image
            }
    }
}

struct LoadingImage_Previews: PreviewProvider {
    static var previews: some View {
        return LoadingImage(
            url: .constant(URL.empty),
            size: .constant(.small),
            downloadImage: { _, _ in
                Just(UIImage.add)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            }
        )
    }
}
