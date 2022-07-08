//
//  ImageStoreTests.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

@testable import MargaritaCore
import TestsCore
import XCTest
import CoreData

class ImageStoreTests: BaseTestCase {

    class Mock {

        struct ImageData: Equatable {
            let data: Data
            let fileName: FileName
        }

        class Output {
            var imagesData = [FileName]()
            var writeImages = [ImageData]()
            var removeImages = [FileName]()
        }

        let imageStore: ImageStore
        let output: Output

        init(objectContext: NSManagedObjectContext) {
            let output = Output()
            imageStore = ImageStore(
                objectContext: objectContext,
                imageData: { fileName in
                    output.imagesData.append(fileName)
                    if let data = output.writeImages.first(where: { $0.fileName == fileName})?.data {
                        return data
                    } else {
                        throw CocoaError(.fileNoSuchFile)
                    }
                },
                writeImage: { data, fileName in
                    output.writeImages.append(ImageData(data: data, fileName: fileName))
                },
                removeImage: { fileName in
                    output.removeImages.append(fileName)
                }
            )
            self.output = output
        }
    }

    func testAddNew() throws {
        let mock = Mock(objectContext: makeObjectContext())
        
        let imageUrl1 = URL(string: "https://domain.com/image1.jpg")!
        let imageSmallData1 = try XCTUnwrap("Small image data 1".data(using: .utf8))
        let imageLargeData1 = try XCTUnwrap("Large image data 1".data(using: .utf8))

        let imageUrl2 = URL(string: "https://domain.com/image2.jpg")!
        let imageSmallData2 = try XCTUnwrap("Small image data 2".data(using: .utf8))
        let imageLargeData2 = try XCTUnwrap("Large image data 2".data(using: .utf8))

        try mock.imageStore.update(imageUrl: imageUrl1, smallImageJpegData: imageSmallData1, largeImageJpegData: imageLargeData1)
        try mock.imageStore.update(imageUrl: imageUrl2, smallImageJpegData: imageSmallData2, largeImageJpegData: imageLargeData2)

        let fetchRequest = try mock.imageStore.makeFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Image.url, ascending: true)]
        let allImages = try mock.imageStore.executeFetchRequest(fetchRequest)

        XCTAssertEqual(allImages.count, 2)
        XCTAssertEqual(allImages[0].url, imageUrl1)
        XCTAssertEqual(allImages[1].url, imageUrl2)

        XCTAssertEqual(mock.output.writeImages.count, 4)
        XCTAssertEqual(mock.output.writeImages[0], Mock.ImageData(data: imageSmallData1, fileName: allImages[0].smallFileName))
        XCTAssertEqual(mock.output.writeImages[1], Mock.ImageData(data: imageLargeData1, fileName: allImages[0].largeFileName))
        XCTAssertEqual(mock.output.writeImages[2], Mock.ImageData(data: imageSmallData2, fileName: allImages[1].smallFileName))
        XCTAssertEqual(mock.output.writeImages[3], Mock.ImageData(data: imageLargeData2, fileName: allImages[1].largeFileName))
    }

    func testUpdate() throws {
        let mock = Mock(objectContext: makeObjectContext())

        let imageUrl1 = URL(string: "https://domain.com/image1.jpg")!
        let imageSmallData1 = try XCTUnwrap("Small image data 1".data(using: .utf8))
        let imageLargeData1 = try XCTUnwrap("Large image data 1".data(using: .utf8))

        try mock.imageStore.update(imageUrl: imageUrl1, smallImageJpegData: imageSmallData1, largeImageJpegData: imageLargeData1)

        let fetchRequest = try mock.imageStore.makeFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Image.url, ascending: true)]
        let allImages = try mock.imageStore.executeFetchRequest(fetchRequest)

        XCTAssertEqual(allImages.count, 1)
        XCTAssertEqual(allImages[0].url, imageUrl1)
        XCTAssertEqual(mock.output.writeImages.count, 2)
        XCTAssertEqual(mock.output.writeImages[0], Mock.ImageData(data: imageSmallData1, fileName: allImages[0].smallFileName))
        XCTAssertEqual(mock.output.writeImages[1], Mock.ImageData(data: imageLargeData1, fileName: allImages[0].largeFileName))
        XCTAssertTrue(mock.output.removeImages.isEmpty)

        let imageOldSmallFileName = allImages[0].smallFileName
        let imageOldLargeFileName = allImages[0].largeFileName

        let imageSmallData2 = try XCTUnwrap("Small image data 2".data(using: .utf8))
        let imageLargeData2 = try XCTUnwrap("Large image data 2".data(using: .utf8))

        try mock.imageStore.update(imageUrl: imageUrl1, smallImageJpegData: imageSmallData2, largeImageJpegData: imageLargeData2)

        let allImages2 = try mock.imageStore.executeFetchRequest(fetchRequest)

        XCTAssertEqual(allImages2.count, 1)
        XCTAssertEqual(allImages2[0].url, imageUrl1)
        XCTAssertEqual(mock.output.writeImages.count, 4)
        XCTAssertEqual(mock.output.writeImages[2], Mock.ImageData(data: imageSmallData2, fileName: allImages2[0].smallFileName))
        XCTAssertEqual(mock.output.writeImages[3], Mock.ImageData(data: imageLargeData2, fileName: allImages2[0].largeFileName))
        XCTAssertEqual(mock.output.removeImages.count, 2)
        XCTAssertEqual(mock.output.removeImages[0], imageOldSmallFileName)
        XCTAssertEqual(mock.output.removeImages[1], imageOldLargeFileName)
    }

    func testImageData() throws {
        let imageUrl = URL(string: "https://domain.com/image1.jpg")!
        let imageSmallData = try XCTUnwrap("Small image data 1".data(using: .utf8))
        let imageLargeData = try XCTUnwrap("Large image data 1".data(using: .utf8))

        let mock = Mock(objectContext: makeObjectContext())

        try mock.imageStore.update(imageUrl: imageUrl, smallImageJpegData: imageSmallData, largeImageJpegData: imageLargeData)

        let fetchRequest = try mock.imageStore.makeFetchRequest()
        let allImages = try mock.imageStore.executeFetchRequest(fetchRequest)

        XCTAssertEqual(allImages.count, 1)

        let cachedImageSmallData = try XCTUnwrap(try mock.imageStore.imageData(with: imageUrl, imageSize: .small))
        let cachedImageLargeData = try XCTUnwrap(try mock.imageStore.imageData(with: imageUrl, imageSize: .large))

        XCTAssertEqual(cachedImageSmallData, imageSmallData)
        XCTAssertEqual(cachedImageLargeData, imageLargeData)
        XCTAssertEqual(mock.output.imagesData.count, 2)
        XCTAssertEqual(mock.output.imagesData[0], allImages[0].smallFileName)
        XCTAssertEqual(mock.output.imagesData[1], allImages[0].largeFileName)

        XCTAssertNil(try mock.imageStore.imageData(with: URL.empty, imageSize: .small))
        XCTAssertEqual(mock.output.imagesData.count, 2)
    }

    func testPurge() throws {
        let mock = Mock(objectContext: makeObjectContext())

        let imageUrl1 = URL(string: "https://domain.com/image1.jpg")!
        let imageSmallData1 = try XCTUnwrap("Small image data 1".data(using: .utf8))
        let imageLargeData1 = try XCTUnwrap("Large image data 1".data(using: .utf8))

        let imageUrl2 = URL(string: "https://domain.com/image2.jpg")!
        let imageSmallData2 = try XCTUnwrap("Small image data 2".data(using: .utf8))
        let imageLargeData2 = try XCTUnwrap("Large image data 2".data(using: .utf8))

        try mock.imageStore.update(imageUrl: imageUrl1, smallImageJpegData: imageSmallData1, largeImageJpegData: imageLargeData1)
        try mock.imageStore.update(imageUrl: imageUrl2, smallImageJpegData: imageSmallData2, largeImageJpegData: imageLargeData2)

        let fetchRequest = try mock.imageStore.makeFetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Image.url, ascending: true)]
        let allImages = try mock.imageStore.executeFetchRequest(fetchRequest)

        XCTAssertEqual(allImages.count, 2)

        let image1OldSmallFileName = allImages[0].smallFileName
        let image1OldLargeFileName = allImages[0].largeFileName

        try mock.imageStore.purge(keepUrls: [imageUrl2])
        let allImages2 = try mock.imageStore.executeFetchRequest(fetchRequest)

        XCTAssertEqual(allImages2.count, 1)
        XCTAssertEqual(allImages2[0].url, imageUrl2)
        XCTAssertEqual(mock.output.removeImages.count, 2)
        XCTAssertEqual(mock.output.removeImages[0], image1OldSmallFileName)
        XCTAssertEqual(mock.output.removeImages[1], image1OldLargeFileName)
    }
}
