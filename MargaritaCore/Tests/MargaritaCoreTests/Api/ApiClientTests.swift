//
//  ApiClientTests.swift
//  
//
//  Created by Damjan on 29.06.2022.
//

import Combine
@testable import MargaritaCore
import TestsCore
import XCTest

class ApiClientTests: BaseTestCase {

    class Mock {
        let apiClient: ApiClient
        let isInternetAvailableSubject: PassthroughSubject<Bool?, Never>
        let dataFromUrlSubject: PassthroughSubject<Data, ApiClientError>

        init() {
            let isInternetAvailableSubject = PassthroughSubject<Bool?, Never>()
            let dataFromUrlSubject = PassthroughSubject<Data, ApiClientError>()
            apiClient = ApiClient(
                isInternetAvailable: isInternetAvailableSubject.eraseToAnyPublisher(),
                dataFromUrl: { _ in
                    dataFromUrlSubject
                        .eraseToAnyPublisher()
                }
            )
            self.isInternetAvailableSubject = isInternetAvailableSubject
            self.dataFromUrlSubject = dataFromUrlSubject
        }
    }

    func testIsInternetAvailableUnknown() {
        let mock = Mock()

        let dataExpectation = expectation(description: "")
        dataExpectation.isInverted = true
        let completionExpectation = expectation(description: "")
        completionExpectation.isInverted = true

        mock.apiClient.data(from: URL.empty)
            .sink { _ in
                XCTFail("Shouldn't have received completion.")
                completionExpectation.fulfill()
            } receiveValue: { _ in
                XCTFail("Shouldn't have received data.")
                dataExpectation.fulfill()
            }
            .store(in: &subscriptions)

        mock.isInternetAvailableSubject.send(nil)

        waitForExpectations(timeout: 0.25)
    }

    func testIsInternetAvailable() {
        let mock = Mock()

        let responseData = "Some data".data(using: .utf8)!
        let dataExpectation = expectation(description: "")
        let completionExpectation = expectation(description: "")

        mock.apiClient.data(from: URL.empty)
            .sink { completion in
                XCTAssertEqual(completion, .finished)
                completionExpectation.fulfill()
            } receiveValue: { data in
                XCTAssertEqual(data, responseData)
                dataExpectation.fulfill()
            }
            .store(in: &subscriptions)

        mock.isInternetAvailableSubject.send(true)
        mock.dataFromUrlSubject.send(responseData)
        mock.dataFromUrlSubject.send(completion: .finished)

        waitForExpectations(timeout: 0.25)
    }

    func testIsInternetNotAvailable() {
        let mock = Mock()

        let dataExpectation = expectation(description: "")
        dataExpectation.isInverted = true
        let completionExpectation = expectation(description: "")

        mock.apiClient.data(from: URL.empty)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, .noInternet)
                } else {
                    XCTFail("Was expecting failure.")
                }
                completionExpectation.fulfill()
            } receiveValue: { _ in
                XCTFail("Shouldn't receive data.")
                dataExpectation.fulfill()
            }
            .store(in: &subscriptions)

        mock.isInternetAvailableSubject.send(false)

        waitForExpectations(timeout: 0.25)
    }

    func testResponseError() {
        let mock = Mock()
        
        let responseError = ApiClientError.unknown
        let dataExpectation = expectation(description: "")
        dataExpectation.isInverted = true
        let completionExpectation = expectation(description: "")

        mock.apiClient.data(from: URL.empty)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTAssertEqual(error, responseError)
                } else {
                    XCTFail("Was expecting failure.")
                }
                completionExpectation.fulfill()
            } receiveValue: { _ in
                XCTFail("Shouldn't receive data.")
                dataExpectation.fulfill()
            }
            .store(in: &subscriptions)

        mock.isInternetAvailableSubject.send(true)
        mock.dataFromUrlSubject.send(completion: .failure(responseError))

        waitForExpectations(timeout: 0.25)
    }
}
