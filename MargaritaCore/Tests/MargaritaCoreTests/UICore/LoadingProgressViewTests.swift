//
//  LoadingProgressViewTests.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

@testable import MargaritaCore
import SnapshotTesting
import SwiftUI
import TestsCore
import XCTest

//
// Snapshots were created using `iPhone 12 mini`.
//
class LoadingProgressViewTests: BaseTestCase {

    func testLoadingProgressView() {
        let view = LoadingProgressView()
            .frame(width: 200, height: 100)
            .background(Color.white)

        assertSnapshot(matching: view.snapshotUIView(), as: .image)
    }
}
