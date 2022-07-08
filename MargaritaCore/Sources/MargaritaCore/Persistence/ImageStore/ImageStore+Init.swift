//
//  ImageStore+Init.swift
//  
//
//  Created by Damjan on 28.06.2022.
//

import Foundation

public extension ImageStore {

    convenience init() {
        let fileManager = DirectoryFileManager(directoryUrl: Persistence.shared.imagesDirectoryUrl)
        self.init(imageData: fileManager.data(from:),
                  writeImage: fileManager.write(_:to:),
                  removeImage: fileManager.remove(_:))
    }
}


