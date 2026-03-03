import XCTest
@testable import VisualpingCore

final class MockAnimationLoader: AnimationLoader {
    var loadedPath: String?
    var loadedFormat: AnimationFormat?
    var result: Result<Void, Error> = .success(())

    func load(from path: String, format: AnimationFormat, completion: @escaping (Result<Void, Error>) -> Void) {
        loadedPath = path
        loadedFormat = format
        completion(result)
    }
}

final class AnimationLoadingTests: XCTestCase {
    var mock: MockAnimationLoader!
    var router: AnimationRouter!

    override func setUp() {
        mock = MockAnimationLoader()
        router = AnimationRouter(loader: mock)
    }

    func testJsonExtensionRoutesToJsonFormat() {
        let exp = expectation(description: "route")
        router.route(filePath: "/path/to/animation.json") { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(mock.loadedFormat, .json)
        XCTAssertEqual(mock.loadedPath, "/path/to/animation.json")
    }

    func testDotLottieExtensionRoutesToDotLottieFormat() {
        let exp = expectation(description: "route")
        router.route(filePath: "/path/to/animation.lottie") { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(mock.loadedFormat, .dotLottie)
    }

    func testExtensionDetectionIsCaseInsensitive() {
        let exp1 = expectation(description: "route1")
        router.route(filePath: "/path/to/ANIMATION.LOTTIE") { _ in exp1.fulfill() }
        wait(for: [exp1], timeout: 1)
        XCTAssertEqual(mock.loadedFormat, .dotLottie)

        let mock2 = MockAnimationLoader()
        let router2 = AnimationRouter(loader: mock2)
        let exp2 = expectation(description: "route2")
        router2.route(filePath: "/path/to/ANIMATION.JSON") { _ in exp2.fulfill() }
        wait(for: [exp2], timeout: 1)
        XCTAssertEqual(mock2.loadedFormat, .json)
    }

    func testNoExtensionDefaultsToJson() {
        let exp = expectation(description: "route")
        router.route(filePath: "/path/to/animation") { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(mock.loadedFormat, .json)
    }

    func testLoaderErrorPropagates() {
        struct LoadError: Error {}
        mock.result = .failure(LoadError())

        let exp = expectation(description: "route")
        router.route(filePath: "/path/to/animation.json") { result in
            if case .success = result {
                XCTFail("Expected error")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
}
