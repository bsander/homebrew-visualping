import Foundation

public struct URLSessionDownloader: URLDownloader {
    public init() {}

    public func download(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let tempURL else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            let ext = url.pathExtension.isEmpty ? "json" : url.pathExtension
            let dest = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)
            do {
                try FileManager.default.moveItem(at: tempURL, to: dest)
                completion(.success(dest))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
