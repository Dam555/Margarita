//
//  DirectoryFileManagerTests.swift
//  
//
//  Created by Damjan on 01.07.2022.
//

@testable import MargaritaCore
import TestsCore
import XCTest

class DirectoryFileManagerTests: BaseTestCase {

    func testData() throws {
        let fileName = "\(UUID().uuidString).txt"
        let fileUrl = imagesDirectoryUrl.appendingPathComponent(fileName)

        try "Some text".write(to: fileUrl, atomically: true, encoding: .utf8)

        XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path))

        let fileManager = DirectoryFileManager(directoryUrl: imagesDirectoryUrl)
        let data = try fileManager.data(from: fileName)
        let fileString = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertEqual(fileString, "Some text")
    }

    func testWrite() throws {
        let fileName = "\(UUID().uuidString).txt"
        let fileUrl = imagesDirectoryUrl.appendingPathComponent(fileName)

        let fileManager = DirectoryFileManager(directoryUrl: imagesDirectoryUrl)
        let data = try XCTUnwrap("Some text".data(using: .utf8))
        try fileManager.write(data, to: fileName)

        XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path))

        let fileData = try Data(contentsOf: fileUrl)

        XCTAssertEqual(fileData, data)
    }

    func testRemove() throws {
        let fileName = "\(UUID().uuidString).txt"
        let fileUrl = imagesDirectoryUrl.appendingPathComponent(fileName)

        XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path))

        try "Some text".write(to: fileUrl, atomically: true, encoding: .utf8)

        XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path))

        let fileManager = DirectoryFileManager(directoryUrl: imagesDirectoryUrl)
        try fileManager.remove(fileName)

        XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path))
    }
}
