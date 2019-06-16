import Foundation
//import Alamofire
import Files

import SimpleHttpClient

open class DownloadManager {
  public enum ClienType {
    case audioKnigi
    case audioBoo
    case bookZvook
  }

  public init() {}

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

  public func downloadAudioKnigiTracks(_ url: String) throws {
    let client = AudioKnigiAPI()

    let path = String(url[AudioKnigiAPI.SiteUrl.index(url.startIndex, offsetBy: AudioKnigiAPI.SiteUrl.count)...])

    let audioTracks = try client.getAudioTracks(path)

    let bookDir = URL(string: url)!.lastPathComponent

    var currentAlbum: String?

    for track in audioTracks {
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

      print("downloadBookZvookTracks \(audioTracks) \(playlistUrl)")

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
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    let fileURL = documentsURL.appendingPathComponent(bookDir).appendingPathComponent(name)

    downloadTrack(from: path, to: fileURL)
  }

  func downloadTrack(from: String, to: URL) {
    if File.exists(atPath: to.path) {
      print("\(to.path) --- exist")

      return
    }

    print(from)

//    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//      return (to, [.removePreviousFile, .createIntermediateDirectories])
//    }
//
//    Alamofire.download(from, to: destination)
//      .downloadProgress(queue: utilityQueue) { progress in
//        //print("Download Progress: \(progress.fractionCompleted)")
//      }
//      .responseData(queue: utilityQueue) { response in
//        if let url = response.destinationURL {
//          FileManager.default.createFile(atPath: url.path, contents: response.result.value)
//        }
//        else {
//          print("Cannot download \(to.path)")
//        }
//
//        semaphore.signal()
//      }
  }
}
