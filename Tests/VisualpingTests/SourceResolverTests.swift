import XCTest
@testable import VisualpingCore

final class MockURLDownloader: URLDownloader {
    var downloadedURL: URL?
    var result: Result<URL, Error> = .failure(URLError(.unknown))

    func download(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        downloadedURL = url
        completion(result)
    }
}

final class SourceResolverTests: XCTestCase {
    var mock: MockURLDownloader!
    var resolver: SourceResolver!

    override func setUp() {
        mock = MockURLDownloader()
        resolver = SourceResolver(downloader: mock)
    }

    func testLocalFilePathReturnsDirectly() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("test-\(UUID().uuidString).json")
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: tempFile) }

        let expectation = expectation(description: "resolve")
        resolver.resolve(tempFile.path) { result in
            switch result {
            case .success(let path):
                XCTAssertEqual(path, tempFile.path)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertNil(mock.downloadedURL, "Should not call downloader for local paths")
    }

    func testHTTPURLCallsDownloader() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("downloaded-\(UUID().uuidString).json")
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: tempFile) }

        mock.result = .success(tempFile)

        let expectation = expectation(description: "resolve")
        resolver.resolve("http://example.com/anim.json") { result in
            switch result {
            case .success(let path):
                XCTAssertEqual(path, tempFile.path)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(mock.downloadedURL?.absoluteString, "http://example.com/anim.json")
    }

    func testHTTPSURLCallsDownloader() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("downloaded-\(UUID().uuidString).json")
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: tempFile) }

        mock.result = .success(tempFile)

        let expectation = expectation(description: "resolve")
        resolver.resolve("https://example.com/anim.lottie") { result in
            if case .failure(let error) = result {
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(mock.downloadedURL?.absoluteString, "https://example.com/anim.lottie")
    }

    func testInvalidURLReturnsError() {
        let expectation = expectation(description: "resolve")
        resolver.resolve("http://not a valid url") { result in
            switch result {
            case .success:
                XCTFail("Expected error for invalid URL")
            case .failure(let error):
                XCTAssertEqual(error, .invalidURL("http://not a valid url"))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testDownloadFailurePropagatesError() {
        mock.result = .failure(URLError(.notConnectedToInternet))

        let expectation = expectation(description: "resolve")
        resolver.resolve("https://example.com/anim.json") { result in
            switch result {
            case .success:
                XCTFail("Expected download error")
            case .failure(let error):
                if case .downloadFailed = error {
                    // Pass
                } else {
                    XCTFail("Expected .downloadFailed, got \(error)")
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testLocalFileNotFoundReturnsError() {
        let expectation = expectation(description: "resolve")
        resolver.resolve("/nonexistent/path/animation.json") { result in
            switch result {
            case .success:
                XCTFail("Expected file not found error")
            case .failure(let error):
                XCTAssertEqual(error, .fileNotFound("/nonexistent/path/animation.json"))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testURLWithNoExtensionDefaultsToJson() {
        let tempFile = FileManager.default.temporaryDirectory
            .appendingPathComponent("downloaded-\(UUID().uuidString).json")
        FileManager.default.createFile(atPath: tempFile.path, contents: Data())
        defer { try? FileManager.default.removeItem(at: tempFile) }

        mock.result = .success(tempFile)

        let expectation = expectation(description: "resolve")
        resolver.resolve("https://example.com/animation") { result in
            if case .failure(let error) = result {
                XCTFail("Unexpected error: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(mock.downloadedURL)
    }
}
