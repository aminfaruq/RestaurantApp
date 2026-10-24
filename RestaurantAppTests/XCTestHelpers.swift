//
//  XCTestHelpers.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import RestaurantApp
import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Should have been deallocated. Potential Memory Leak", file: file, line: line)
        }
    }
}

@MainActor
class HTTPClientSpy: HTTPClient {
    
    enum Message: Equatable {
        case get(URL)
        case post(URL, headers: [String : String]?, body: HTTPBody?)
    }
    
    private(set) var messages = [Message]()
    
    var requestedURLs : [URL] {
        messages.map({ message in
            switch message {
                case .get(let uRL):
                    return uRL
                case .post(let uRL, _, _):
                    return uRL
            }
        })
    }
    
    private var stub: Result<HTTPClient.Result, Error>?
    
    func stub(withStatusCode code: Int, data: Data) {
        self.stub = .success(makeResponse(statusCode: code, data: data))
    }
    
    func stub(withError error: Error) {
        self.stub = .failure(error)
    }
    
    func get(from url: URL) async throws -> HTTPClient.Result {
        messages.append(.get(url))
        return try stub?.get() ?? makeResponse(statusCode: 200)
    }
    
    func post(from url: URL, headers: [String : String]?, body: HTTPBody?) async throws -> HTTPClient.Result {
        messages.append(.post(url, headers: headers, body: body))
        return try stub?.get() ?? makeResponse(statusCode: 200)
    }
}

func assertThat(
    _ action: () async throws -> (),
    throws expectedError: NetworkError,
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        try await action()
        XCTFail("Expected \(expectedError), received nothing", file: file, line: line)
    } catch let error as NetworkError {
        XCTAssertEqual(error, expectedError, file: file, line: line)
        XCTAssertNotNil(error.localizedDescription, file: file, line: line)
    } catch {
        XCTFail("Expected \(expectedError), got failure \(error)", file: file, line: line)
    }
}

func anyError() -> NSError {
    NSError(domain: "an error", code: 1)
}

func anyURL() -> URL {
    URL(string: "http://any-url")!
}

func makeResponse(statusCode: Int ,data: Data = Data()) -> HTTPClient.Result {
    let response = HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    return (data, response)
}
