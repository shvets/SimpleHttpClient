import Foundation

public enum DownloadError: Error {
  case downloadFailed(_ message: String)
}

open class DownloadManager {
  public let fileManager = FileManager.default

  public init() {}

  public func downloadFrom(_ url: URL, toUrl: URL) throws {
    if let baseUrl = getBaseUrl(url) {
      let apiClient = ApiClient(baseUrl)

      let response = try apiClient.request(url.path)

      if let data = response.data {
        try createFile(url: toUrl, contents: data)
      }
      else {
        throw DownloadError.downloadFailed("Cannot download \(toUrl.path)")
      }
    }
  }

  func createFile(url: URL, contents: Data) throws {
    let file = url.path
    let dir = url.deletingLastPathComponent()

    try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)

    fileManager.createFile(atPath: file, contents: contents)
  }

  func getBaseUrl(_ url: URL) -> URL? {
    var urlComponents = URLComponents()
    urlComponents.scheme = url.scheme
    urlComponents.host = url.host

    return urlComponents.url
  }
}