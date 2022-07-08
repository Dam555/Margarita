//
//  ImageStore.swift
//  
//
//  Created by Damjan on 17.05.2022.
//

import CoreData

public enum ImageStoreImageSize {
    case small
    case large
}

public typealias KeepImageUrl = URL

public class ImageStore: Store<Image> {

    public let imageData: (FileName) throws -> Data
    public let writeImage: (Data, FileName) throws -> Void
    public let removeImage: (FileName) throws -> Void

    public init(objectContext: NSManagedObjectContext = Persistence.shared.makeObjectContext(),
                imageData: @escaping (FileName) throws -> Data,
                writeImage: @escaping (Data, FileName) throws -> Void,
                removeImage: @escaping (FileName) throws -> Void) {
        self.imageData = imageData
        self.writeImage = writeImage
        self.removeImage = removeImage
        super.init(objectContext: objectContext)
    }

    public func imageData(with url: URL, imageSize: ImageStoreImageSize) throws -> Data? {
        guard let image = try self.image(with: url) else { return nil }

        let imageFileName: String?
        switch imageSize {
        case .small: imageFileName = image.smallFileName
        case .large: imageFileName = image.largeFileName
        }

        guard let imageFileName = imageFileName else { return nil }

        do {
            return try imageData(imageFileName)
        } catch {
            throw StoreError.objectNotFound
        }
    }

    public func update(imageUrl: URL, smallImageJpegData: Data, largeImageJpegData: Data) throws {
        // Save new image files.
        let smallImageFileName = "\(UUID().uuidString).jpg"
        let largeImageFileName = "\(UUID().uuidString).jpg"
        do {
            try writeImage(smallImageJpegData, smallImageFileName)
            try writeImage(largeImageJpegData, largeImageFileName)
        } catch {
            do {
                try removeImage(smallImageFileName)
                try removeImage(largeImageFileName)
            } catch { }
            throw StoreError.objectNotCreated
        }

        // Update existing image or add new one.
        let image: Image
        if let currrentImage = try self.image(with: imageUrl) {
            image = currrentImage
            // Delete old image files.
            do {
                try removeImage(image.smallFileName)
                try removeImage(image.largeFileName)
            } catch { }
        } else {
            image = addObject()
            image.url = imageUrl
        }

        image.smallFileName = smallImageFileName
        image.largeFileName = largeImageFileName

        try save()
    }

    public func purge(keepUrls: [KeepImageUrl]) throws {
        let fetchRequest = try makeFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "NOT (url IN %@)", keepUrls)
        let unusedImages = try executeFetchRequest(fetchRequest)
        for image in unusedImages {
            // Delete unused image files.
            do {
                try removeImage(image.smallFileName)
                try removeImage(image.largeFileName)
            } catch { }
            deleteObject(image)
        }
        try save()
    }
}

private extension ImageStore {

    func image(with url: URL) throws -> Image? {
        let fetchRequest = try makeFetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", url as CVarArg)
        fetchRequest.fetchLimit = 1
        return try executeFetchRequest(fetchRequest).first
    }
}
