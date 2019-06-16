import Foundation
import Files

import SimpleHttpClient

open class DownloadManager {
  public enum ClienType {
    case audioKnigi
    case audioBoo
    case bookZvook
  }

  public func download(clientType: ClienType, url: String) throws {
    switch clientType {
      case .audioKnigi:
        try downloadAudioKnigiTracks(url)
      case .audioBoo:
        try downloadAudioBooTracks(url)
      case .bookZvook:
        try downloadBookZvookTracks(url)
    }
  }

  private let fileManager = FileManager.default

  public init() {}

  public func downloadAudioKnigiTracks(_ url: String) throws {
    let client = AudioKnigiAPI()

    let path = String(url[AudioKnigiAPI.SiteUrl.index(url.startIndex, offsetBy: AudioKnigiAPI.SiteUrl.count)...])

    let audioTracks = try client.getAudioTracks(path)

    let bookDir = URL(string: url)!.lastPathComponent

    var currentAlbum: String?

    for track in audioTracks {
      print(track)

      if !track.albumName!.isEmpty {
        currentAlbum = track.albumName
      }

      let path = track.url
      let name = track.title

      let encodedPath = path!.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

      download(name: "\(name).mp3", path: encodedPath, bookDir: currentAlbum == nil ? bookDir :  bookDir + currentAlbum!)
    }
  }

  public func downloadAudioBooTracks(_ url: String) throws {
    let client = AudioBooAPI()

    let playlistUrls = try client.getPlaylistUrls(url)

    if playlistUrls.count > 0 {
      let playlistUrl = playlistUrls[0]

      let audioTracks = try client.getAudioTracks(playlistUrl)

      var bookDir = URL(string: url)!.lastPathComponent
      bookDir = String(bookDir[...bookDir.index(bookDir.endIndex, offsetBy: -".html".count-1)])

      for track in audioTracks {
        print(track)

        let path = "\(AudioBooAPI.ArchiveUrl)\(track.sources[0].file)"
        let name = track.orig

        download(name: name, path: path, bookDir: bookDir)
      }
    }
    else {
      print("Cannot find playlist.")
    }
  }

  public func downloadBookZvookTracks(_ url: String) throws {
    let client = BookZvookAPI()

    let playlistUrls = try client.getPlaylistUrls(url)

    if playlistUrls.count > 0 {
      let playlistUrl = playlistUrls[0]

      let audioTracks = try client.getAudioTracks(playlistUrl)

      var bookDir = URL(string: url)!.lastPathComponent
      bookDir = String(bookDir[...bookDir.index(bookDir.endIndex, offsetBy: -".html".count-1)])

      for track in audioTracks {
        print(track)

        let path = "\(AudioBooAPI.ArchiveUrl)\(track.sources[0].file)"
        let name = track.orig

        download(name: name, path: path, bookDir: bookDir)
      }
    }
    else {
      print("Cannot find playlist.")
    }
  }

  func download(name: String, path: String, bookDir: String) {
    let documentsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]

    let fileURL = documentsURL.appendingPathComponent(bookDir).appendingPathComponent(name)

    downloadTrack(from: path, to: fileURL)
  }

  func downloadTrack(from: String, to: URL) {
    if File.exists(atPath: to.path) {
      print("\(to.path) --- exist")

      return
    }

    if let fromUrl = URL(string: from) {
      var urlComponents = URLComponents()
      urlComponents.scheme = fromUrl.scheme
      urlComponents.host = fromUrl.host

      if let baseUrl = urlComponents.url {
        let apiClient = ApiClient(baseUrl)

        let destinationFile = to.path
        let destinationDir = to.deletingLastPathComponent()

        do {
          if let response = try apiClient.request(fromUrl.path), let data = response.body {
            try self.fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)

            self.fileManager.createFile(atPath: destinationFile, contents: data)
          }
          else {
            print("Cannot download \(destinationFile)")
          }
        }
        catch {
          print("Error: \(error.localizedDescription)")
        }
      }
    }
  }
}
