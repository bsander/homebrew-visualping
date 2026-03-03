import Foundation

public protocol URLDownloader {
    func download(from url: URL, completion: @escaping (Result<URL, Error>) -> Void)
}

public enum SourceError: Error, Equatable {
    case invalidURL(String)
    case downloadFailed(String)
    case fileNotFound(String)
}

public struct SourceResolver {
    public let downloader: URLDownloader

    public init(downloader: URLDownloader) {
        self.downloader = downloader
    }

    public func resolve(_ source: String, completion: @escaping (Result<String, SourceError>) -> Void) {
        if source.hasPrefix("http://") || source.hasPrefix("https://") {
            guard let url = URL(string: source) else {
                completion(.failure(.invalidURL(source)))
                return
            }
            downloader.download(from: url) { result in
                switch result {
                case .success(let fileURL):
                    completion(.success(fileURL.path))
                case .failure(let error):
                    completion(.failure(.downloadFailed(error.localizedDescription)))
                }
            }
        } else {
            guard FileManager.default.fileExists(atPath: source) else {
                completion(.failure(.fileNotFound(source)))
                return
            }
            completion(.success(source))
        }
    }
}
