//
//  URLSessionHTTPClientTests.swift
//  RestaurantApp
//
//  Created by Amin faruq on 23/10/26.
//

import XCTest
import RestaurantApp

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stub = nil
    }
    
    func test_getFromURL_requestFromURL() async {
        let url = anyURL()
        let exp = expectation(description: "Wait from GET Response")
        
        URLProtocolStub.stub = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
            return makeResponse(statusCode: 200)
        }
        
        _ = try? await makeSUT().get(from: url)
        
        await fulfillment(of: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_deliversResultOnFailure() async {
        let expectedError = anyError()
        
        URLProtocolStub.stub = { _ in
            throw expectedError
        }
                
        do {
            _ = try await makeSUT().get(from: anyURL())
            XCTFail("Expected error, got success")
        } catch let error as NSError {
            XCTAssertEqual(error.code, expectedError.code)
            XCTAssertEqual(error.domain, expectedError.domain)
        }
    }
    
    func test_getFromURL_deliversResultOnSuccess() async throws {
        let json = "Any Json".data(using: .utf8)!
        let (data, response) = makeResponse(statusCode: 200, data: json)
        
        URLProtocolStub.stub = { _ in
            return (data, response)
        }
                
        let (receivedData, receivedResponse) = try await makeSUT().get(from: anyURL())
        XCTAssertEqual(receivedData, data)
        XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        XCTAssertEqual(receivedResponse.url, response.url)
    }
    
    @MainActor
    func test_postFromURL_requestFromURL() async {
        let url = anyURL()
        let exp = expectation(description: "Wait from POST Response")
        let jsonBody = "{\"title\": \"ABC\"}".data(using: .utf8)!
        let mockBody = HTTPBody(data: jsonBody, contentType: .json)
        let httpHeader = ["Autorization": "8508502385032q80rjfz"]
        URLProtocolStub.stub = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.httpBodyData, jsonBody)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Autorization"), "8508502385032q80rjfz")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            
            exp.fulfill()
            return makeResponse(statusCode: 200)
        }
        
        _ = try? await makeSUT().post(from: url, headers: httpHeader, body: mockBody)

        
        await fulfillment(of: [exp], timeout: 1.0)
    }
    
    func test_postFromURL_deliversResultOnFailure() async {
        let expectedError = anyError()
        
        URLProtocolStub.stub = { _ in
            throw expectedError
        }
                
        do {
            _ = try await makeSUT().post(from: anyURL(), headers: nil, body: nil)
            XCTFail("Expected error, got success")
        } catch let error as NSError {
            XCTAssertEqual(error.code, expectedError.code)
            XCTAssertEqual(error.domain, expectedError.domain)
        }
    }
    
    func test_postFromURL_deliversResultOnSuccess() async throws {
        let json = "Any Json".data(using: .utf8)!
        let (data, response) = makeResponse(statusCode: 200, data: json)
        
        URLProtocolStub.stub = { _ in
            return (data, response)
        }
                
        let (receivedData, receivedResponse) = try await makeSUT().post(from: anyURL(), headers: nil, body: nil)
        XCTAssertEqual(receivedData, data)
        XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
        XCTAssertEqual(receivedResponse.url, response.url)
    }
    
    //MARK: - Helpers
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        static var stub: ((URLRequest) throws -> HTTPClient.Result)?
        
        override class func canInit(with request: URLRequest) -> Bool {
            return URLProtocolStub.stub != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            do {
                let (data, response) = try stub(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() {}
    }
    
}

private extension URLRequest {
    var httpBodyData: Data? {
        if let httpBody = httpBody { return httpBody }
        guard let stream = httpBodyStream else { return nil }
        stream.open()
        defer { stream.close() }
        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read > 0 {
                data.append(buffer, count: read)
            } else {
                break
            }
        }
        return data
    }
}
