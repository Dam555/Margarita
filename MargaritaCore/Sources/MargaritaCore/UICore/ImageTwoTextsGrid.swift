//
//  SwiftUIView.swift
//  
//
//  Created by Damjan on 18.05.2022.
//

import Combine
import SwiftUI

public struct ImageTwoTextsGrid: View {

    @Binding var imageUrl: URL
    @Binding var topText: String
    @Binding var bottomText: String
    let downloadImage: (URL, ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>

    private let layout = Layout()

    public init(imageUrl: Binding<URL>,
                topText: Binding<String>,
                bottomText: Binding<String>,
                downloadImage: @escaping (URL, ImageStoreImageSize) -> AnyPublisher<UIImage, ImageDownloaderError>) {
        self._imageUrl = imageUrl
        self._topText = topText
        self._bottomText = bottomText
        self.downloadImage = downloadImage
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                LoadingImage(url: _imageUrl, size: .constant(.small), downloadImage: downloadImage)
                    .frame(width: layout.imageSize.width, height: layout.imageSize.height)
                VStack(alignment: .leading, spacing: layout.textsSpacing) {
                    Text(topText)
                        .font(layout.topTextFont)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(bottomText)
                        .font(layout.bottomTextFont)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(layout.textsPadding)
            }
            .padding(layout.padding)
        }
    }
}

private extension ImageTwoTextsGrid {

    struct Layout {
        let padding = EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0)
        let imageSize = CGSize(width: 44, height: 44)
        let textsPadding = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        let textsSpacing: CGFloat = 8
        let topTextFont = Font.system(size: 20)
        let bottomTextFont = Font.system(size: 16)
        let dividerOffsetX: CGFloat = 26.3
    }
}

struct ImageTwoTextsGrid_Previews: PreviewProvider {
    static var previews: some View {
        ImageTwoTextsGrid(
            imageUrl: .constant(URL.empty),
            topText: .constant("Top Text"),
            bottomText: .constant("Bottom Text"),
            downloadImage: { _, _ in
                Just(UIImage.add)
                    .setFailureType(to: ImageDownloaderError.self)
                    .eraseToAnyPublisher()
            }
        )
    }
}
