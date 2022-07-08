//
//  ApiIntegrationTests.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

import Combine
@testable import MargaritaCore
import TestsCore
import XCTest

class MargaritaApiIntegrationTests: BaseTestCase {

    func testGetMargaritaCocktails() {
        let api = Api()

        let cocktailsExpectation = expectation(description: "")
        let finishedExpectation = expectation(description: "")

        api.getMargaritaCocktails()
            .sink { completion in
                switch completion {
                case .failure:
                    XCTFail("Shouldn't have failed")
                case .finished:
                    finishedExpectation.fulfill()
                }
            } receiveValue: { cocktails in
                XCTAssertFalse(cocktails.isEmpty)
                cocktailsExpectation.fulfill()
            }
            .store(in: &subscriptions)


        waitForExpectations(timeout: 10)
    }
}
