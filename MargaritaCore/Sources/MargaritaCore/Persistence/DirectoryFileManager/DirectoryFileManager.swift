//
//  DirectoryFileManager.swift
//  
//
//  Created by Damjan on 27.06.2022.
//

import Foundation

public typealias FileName = String

public class DirectoryFileManager {

    public let directoryUrl: URL

    public init(directoryUrl: URL) {
        self.directoryUrl = directoryUrl
    }

    public func data(from fileName: FileName) throws -> Data {
        try Data(contentsOf: directoryUrl.appendingPathComponent(fileName))
    }

    public func write(_ data: Data, to fileName: FileName) throws {
        try data.write(to: directoryUrl.appendingPathComponent(fileName), options: .atomic)
    }

    public func remove(_ fileName: FileName) throws {
        guard !fileName.isEmpty else { return }
        let url = directoryUrl.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
