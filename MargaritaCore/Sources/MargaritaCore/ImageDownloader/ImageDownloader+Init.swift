//
//  ImageDownloader+Init.swift
//  
//
//  Created by Damjan on 28.06.2022.
//

import Foundation

public extension ImageDownloader {

    convenience init() {
        let apiClient = ApiClient()
        let imageStore = ImageStore()
        self.init(imageData: apiClient.data(from:),
                  cachedImageData: imageStore.imageData(with:imageSize:),
                  updateCachedImage: imageStore.update(imageUrl:smallImageJpegData:largeImageJpegData:))
    }
}
