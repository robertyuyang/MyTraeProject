//
//  LLMCategorizingServiceTests.swift
//  MyTraeProjectTests
//
//  Created by ByteDance on 2026/4/17.
//

import XCTest
@testable import MyTraeProject

class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class LLMCategorizingServiceTests: XCTestCase {

    var sut: LLMCategorizingService!
    var mockSession: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        sut = LLMCategorizingService(session: mockSession)
    }

    override func tearDown() {
        sut = nil
        mockSession = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testParseItemsWithValidJSON() {
        let json = """
        [{"name":"护照","priority":0,"category":"Documents & IDs"},{"name":"充电器","priority":1,"category":"Electronics"}]
        """
        let items = sut.parseItems(from: json)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].name, "护照")
        XCTAssertEqual(items[0].defaultPriority, .p0)
        XCTAssertEqual(items[0].category, BuiltInCategory.documentsAndIDs)
        XCTAssertEqual(items[1].name, "充电器")
        XCTAssertEqual(items[1].defaultPriority, .p1)
        XCTAssertEqual(items[1].category, BuiltInCategory.electronics)
    }

    func testParseItemsWithMarkdownWrappedJSON() {
        let json = """
        ```json
        [{"name":"牙刷","priority":2,"category":"Toiletries"}]
        ```
        """
        let items = sut.parseItems(from: json)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].name, "牙刷")
        XCTAssertEqual(items[0].defaultPriority, .p2)
        XCTAssertEqual(items[0].category, BuiltInCategory.toiletries)
    }

    func testParseItemsWithInvalidCategory() {
        let json = """
        [{"name":"伞","priority":1,"category":"InvalidCategory"}]
        """
        let items = sut.parseItems(from: json)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].category, BuiltInCategory.other)
    }

    func testParseItemsWithMissingPriority() {
        let json = """
        [{"name":"毛巾","category":"Toiletries"}]
        """
        let items = sut.parseItems(from: json)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].defaultPriority, .p2)
    }

    func testParseItemsWithInvalidPriority() {
        let json = """
        [{"name":"帽子","priority":99,"category":"Clothing"}]
        """
        let items = sut.parseItems(from: json)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].defaultPriority, .p2)
    }

    func testParseItemsWithEmptyName() {
        let json = """
        [{"name":"","priority":0,"category":"Documents"},{"name":"手机","priority":0,"category":"Electronics"}]
        """
        let items = sut.parseItems(from: json)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].name, "手机")
    }

    func testParseItemsWithInvalidJSON() {
        let items = sut.parseItems(from: "this is not json")
        XCTAssertTrue(items.isEmpty)
    }

    func testParseItemsWithEmptyArray() {
        let items = sut.parseItems(from: "[]")
        XCTAssertTrue(items.isEmpty)
    }

    func testCategorizeSuccess() {
        let expectation = expectation(description: "categorize completion")

        let responseJSON: [String: Any] = [
            "choices": [
                [
                    "message": [
                        "content": "[{\"name\":\"身份证\",\"priority\":0,\"category\":\"Documents & IDs\"},{\"name\":\"T恤\",\"priority\":2,\"category\":\"Clothing\"}]"
                    ]
                ]
            ]
        ]
        let responseData = try! JSONSerialization.data(withJSONObject: responseJSON)

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            XCTAssertTrue(request.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer ") ?? false)

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }

        sut.categorize(text: "我必须带身份证，还有几件T恤") { result in
            switch result {
            case .success(let items):
                XCTAssertEqual(items.count, 2)
                XCTAssertEqual(items[0].name, "身份证")
                XCTAssertEqual(items[0].defaultPriority, .p0)
                XCTAssertEqual(items[0].category, BuiltInCategory.documentsAndIDs)
                XCTAssertEqual(items[1].name, "T恤")
                XCTAssertEqual(items[1].defaultPriority, .p2)
                XCTAssertEqual(items[1].category, BuiltInCategory.clothing)
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testCategorizeNetworkError() {
        let expectation = expectation(description: "categorize error")

        MockURLProtocol.requestHandler = { _ in
            throw NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        }

        sut.categorize(text: "带个手机") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure:
                break
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testCategorizeInvalidResponseFormat() {
        let expectation = expectation(description: "categorize invalid response")

        let invalidResponse: [String: Any] = ["unexpected": "format"]
        let responseData = try! JSONSerialization.data(withJSONObject: invalidResponse)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }

        sut.categorize(text: "带个手机") { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure:
                break
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testRequestBodyContainsCorrectModel() {
        let expectation = expectation(description: "check request body")

        let responseJSON: [String: Any] = [
            "choices": [["message": ["content": "[]"]]]
        ]
        let responseData = try! JSONSerialization.data(withJSONObject: responseJSON)

        MockURLProtocol.requestHandler = { request in
            let bodyData = request.httpBody ?? request.httpBodyStream.flatMap { stream -> Data? in
                stream.open()
                var data = Data()
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
                while stream.hasBytesAvailable {
                    let count = stream.read(buffer, maxLength: 1024)
                    if count > 0 { data.append(buffer, count: count) }
                }
                buffer.deallocate()
                stream.close()
                return data
            }
            if let bodyData = bodyData,
               let body = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] {
                XCTAssertEqual(body["model"] as? String, "doubao-seed-2.0-pro")
                XCTAssertNotNil(body["messages"])
            }

            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, responseData)
        }

        sut.categorize(text: "测试") { _ in
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

}
