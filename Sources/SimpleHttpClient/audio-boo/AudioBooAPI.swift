import Foundation
import SwiftSoup

open class AudioBooAPI {
  public static let SiteUrl = "http://audioboo.ru"
  public static let ArchiveUrl = "https://archive.org"

  let apiClient = ApiClient(URL(string: SiteUrl)!)
  let archiveClient = ApiClient(URL(string: ArchiveUrl)!)

  public init() {}

  public static func getURLPathOnly(_ url: String, baseUrl: String) -> String {
    return String(url[baseUrl.index(url.startIndex, offsetBy: baseUrl.count)...])
  }

  func getPagePath(path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page/\(page)/"
    }
  }

  public func getLetters() throws -> [[String: String]] {
    var result = [[String: String]]()

    if let document = try self.getDocument() {
      let items = try document.select("div[class=content] div div a[class=alfavit]")

      for item in items.array() {
        let name = try item.text()

        let href = try item.attr("href")

        result.append(["id": href, "name": name.uppercased()])
      }
    }

    return result
  }

  public func getAuthorsByLetter(_ path: String) throws -> [NameClassifier.ItemsGroup] {
    var groups: [String: [NameClassifier.Item]] = [:]

    if let document = try self.getDocument(path) {
      let items = try document.select("div[class=full-news-content] div a")

      for item in items.array() {
        let href = try item.attr("href")
        let name = try item.text().trim()

        if !name.isEmpty && !name.hasPrefix("ALIAS") && Int(name) == nil {
          let index1 = name.startIndex
          let index2 = name.index(name.startIndex, offsetBy: 3)

          let groupName = name[index1 ..< index2].uppercased()

          if !groups.keys.contains(groupName) {
            groups[groupName] = []
          }

          var group: [NameClassifier.Item] = []

          if let subGroup = groups[groupName] {
            for item in subGroup {
              group.append(item)
            }
          }

          group.append(NameClassifier.Item(id: href, name: name))

          groups[groupName] = group
        }
      }
    }

    var newGroups: [NameClassifier.ItemsGroup] = []

    for (groupName, group) in groups.sorted(by: { $0.key < $1.key}) {
      newGroups.append(NameClassifier.ItemsGroup(key: groupName, value: group))
    }

    return NameClassifier().mergeSmallGroups(newGroups)
  }

  public func getAllBooks(page: Int=1) throws -> [BookItem] {
    var result = [BookItem]()

    let path = getPagePath(path: "", page: page)

    if let document = try self.getDocument(path) {
      let items = try document.select("div[id=dle-content] div[class=biography-main]")

      for item: Element in items.array() {
        let name = try item.select("div[class=biography-title] h2 a").text()
        let href = try item.select("div div[class=biography-image] a").attr("href")
        let thumb = try item.select("div div[class=biography-image] a img").attr("src")

        result.append(["type": "book", "id": href, "name": name, "thumb": AudioBooAPI.SiteUrl + thumb])
      }
    }

    return result
  }

  public func getBooks(_ url: String, page: Int=1) throws -> [BookItem] {
    var result = [BookItem]()

    let path = getPagePath(path: "", page: page)

    if let document = try self.getDocument(path) {
      let items = try document.select("div[class=biography-main]")

      for item: Element in items.array() {
        let name = try item.select("div[class=biography-title] h2 a").text()
        let href = try item.select("div div[class=biography-image] a").attr("href")
        let thumb = try item.select("div div[class=biography-image] a img").attr("src")

        let elements = try item.select("div[class=biography-content] div").array()

        let content = try elements[0].text()
        let rating = try elements[2].select("div[class=rating] ul li[class=current-rating]").text()

        result.append(["type": "book", "id": href, "name": name, "thumb": AudioBooAPI.SiteUrl + thumb, 
                       "content": content, "rating": rating])
      }
    }

    return result
  }

  public func getPlaylistUrls(_ url: String) throws -> [String] {
    var result = [String]()

    let path = AudioBooAPI.getURLPathOnly(url, baseUrl: AudioBooAPI.SiteUrl)

    if let document = try self.getDocument(path) {
      let items = try document.select("object")

      for item: Element in items.array() {
        result.append(try item.attr("data"))
      }
    }

    return result
  }

  public func getAudioTracks(_ url: String) throws -> [BooTrack] {
    var result = [BooTrack]()

    let path = AudioBooAPI.getURLPathOnly(url, baseUrl: AudioBooAPI.ArchiveUrl)

    if let response = try archiveClient.request(path), let data = response.data,
       let document = try self.toDocument(data: data, encoding: .utf8) {

      let items = try document.select("input[class=js-play8-playlist]")

      for item in items.array() {
        let value = try item.attr("value")

        if let data = value.data(using: .utf8),
           let tracks = try archiveClient.decode(data, to: [BooTrack].self) {
          result = tracks
        }
      }
    }

    return result
  }

  public func search(_ query: String, page: Int=1) throws -> [[String: String]] {
    var result = [[String: String]]()

    let path = "engine/ajax/search.php"

    let content = "query=\(query)"
    let body = content.data(using: .utf8, allowLossyConversion: false)

    if let response = try apiClient.request(path, method: .post, body: body),
       let data = response.data,
       let document = try self.toDocument(data: data) {
      let items = try document.select("a")

      for item in items.array() {
        let name = try item.text()

        let href = try item.attr("href")

        result.append(["type": "book", "id": href, "name": name])
      }
    }

    return result
  }

  public func getDocument(_ path: String = "") throws -> Document? {
    var document: Document? = nil

    if let response = try apiClient.request(path), let data = response.data {
      document = try data.toDocument(encoding: .windowsCP1251)
    }

    return document
  }

  func toDocument(data: Data, encoding: String.Encoding = .windowsCP1251) throws -> Document? {
    return try data.toDocument(encoding: encoding)
  }
}
