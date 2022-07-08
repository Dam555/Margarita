//
//  ApiTests.swift
//  
//
//  Created by Damjan on 19.05.2022.
//

import Combine
@testable import MargaritaCore
import TestsCore
import XCTest

class ApiTests: BaseTestCase {

    class Mock {
        let api: Api
        let dataFromUrlSubject: PassthroughSubject<Data, ApiClientError>

        init() {
            let dataFromUrlSubject = PassthroughSubject<Data, ApiClientError>()
            api = Api(
                dataFromUrl: { _ in
                    dataFromUrlSubject
                        .eraseToAnyPublisher()
                }
            )
            self.dataFromUrlSubject = dataFromUrlSubject
        }
    }

    func testGetMargaritaCocktailsWithErrorUnknown() {
        let mock = Mock()

        let failureExpectation = expectation(description: "")

        mock.api.getMargaritaCocktails()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, .unknown)
                    failureExpectation.fulfill()
                case .finished:
                    XCTFail("Shouldn't have finished normally")
                }
            } receiveValue: { _ in
                XCTFail("Shouldn't have received cocktails")
            }
            .store(in: &subscriptions)

        mock.dataFromUrlSubject.send(completion: .failure(.unknown))

        waitForExpectations(timeout: 0.25)
    }

    func testGetMargaritaCocktailsWithErrorInvalidJson() {
        let mock = Mock()

        let failureExpectation = expectation(description: "")

        mock.api.getMargaritaCocktails()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, .invalidJson)
                    failureExpectation.fulfill()
                case .finished:
                    XCTFail("Shouldn't have finished normally")
                }
            } receiveValue: { _ in
                XCTFail("Shouldn't have received cocktails")
            }
            .store(in: &subscriptions)

        mock.dataFromUrlSubject.send(Data())
        mock.dataFromUrlSubject.send(completion: .finished)

        waitForExpectations(timeout: 0.25)
    }

    func testGetMargaritaCocktails() throws {
        let mock = Mock()
        
        let cocktailsExpectation = expectation(description: "")
        let finishedExpectation = expectation(description: "")

        mock.api.getMargaritaCocktails()
            .sink { completion in
                switch completion {
                case .failure:
                    XCTFail("Shouldn't have failed")
                case .finished:
                    finishedExpectation.fulfill()
                }
            } receiveValue: { cocktails in
                XCTAssertEqual(cocktails.count, 1)
                XCTAssertEqual(cocktails[0].id, "1")
                XCTAssertEqual(cocktails[0].name, "Name")
                XCTAssertEqual(cocktails[0].glass, "Glass")
                XCTAssertEqual(cocktails[0].instructions, "Instructions")
                XCTAssertEqual(cocktails[0].imageUrl, URL(string: "about:blank")!)
                cocktailsExpectation.fulfill()
            }
            .store(in: &subscriptions)

        let json = """
            {
                "drinks": [
                    {
                        "idDrink": "1",
                        "strDrink": "Name",
                        "strGlass": "Glass",
                        "strInstructions": "Instructions",
                        "strDrinkThumb": "about:blank"
                    }
                ]
            }
        """

        let jsonData = try XCTUnwrap(json.data(using: .utf8))
        mock.dataFromUrlSubject.send(jsonData)
        mock.dataFromUrlSubject.send(completion: .finished)

        waitForExpectations(timeout: 0.25)
    }
}
