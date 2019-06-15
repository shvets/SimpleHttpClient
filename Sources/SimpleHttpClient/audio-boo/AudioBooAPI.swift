import Foundation
import SwiftSoup

open class AudioBooAPI {
  public static let SiteUrl = "http://audioboo.ru"
  public static let ArchiveUrl = "https://archive.org"

  let apiClient = ApiClient(URL(string: SiteUrl)!)

//  public func searchDocument(_ url: String, parameters: [String: String]) throws -> Document? {
//    let headers = ["X-Requested-With": "XMLHttpRequest"]
//
//    return try fetchDocument(url, headers: headers, parameters: parameters, method: .post, encoding: .windowsCP1251)
//  }

  public func getLetters() throws -> [[String: String]] {
    var result = [[String: String]]()

    if let response = try apiClient.request(""), let data = response.body,
       let document = try self.toDocument(data: data) {
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

    if let response = try apiClient.request(path), let data = response.body,
      let document = try self.toDocument(data: data) {
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

  public func getAllBooks(page: Int=1) throws -> [Any] {
    var data = [Any]()

    let pagePath = page == 1 ? "" : "page/\(page)/"

    print(AudioBooAPI.SiteUrl + "/" + pagePath)

//    if let document = try getDocument(AudioBooAPI.SiteUrl + "/" + pagePath) {
//      let items = try document.select("div[id=dle-content] div[class=biography-main]")
//
//      for item: Element in items.array() {
//        let name = try item.select("div[class=biography-title] h2 a").text()
//        let href = try item.select("div div[class=biography-image] a").attr("href")
//        let thumb = try item.select("div div[class=biography-image] a img").attr("src")
//
//        data.append(["type": "book", "id": href, "name": name, "thumb": AudioBooAPI.SiteUrl + thumb])
//      }
//    }

    return data
  }

//  public func getBooks(_ url: String, page: Int=1) throws -> [Any] {
//    var data = [Any]()
//
//    let pagePath = page == 1 ? "" : "page/\(page)/"
//
//    if let document = try getDocument(url + pagePath) {
//      let items = try document.select("div[class=biography-main]")
//
//      for item: Element in items.array() {
//        let name = try item.select("div[class=biography-title] h2 a").text()
//        let href = try item.select("div div[class=biography-image] a").attr("href")
//        let thumb = try item.select("div div[class=biography-image] a img").attr("src")
//
//        let elements = try item.select("div[class=biography-content] div").array()
//
//        let content = try elements[0].text()
//        let rating = try elements[2].select("div[class=rating] ul li[class=current-rating]").text()
//
//        data.append(["type": "book", "id": href, "name": name, "thumb": AudioBooAPI.SiteUrl + thumb, "content": content, "rating": rating])
//      }
//    }
//
//    return data
//  }
//
//  public func getPlaylistUrls(_ url: String) throws -> [String] {
//    var data = [String]()
//
//    if let document = try getDocument(url) {
//      let items = try document.select("object")
//
//      for item: Element in items.array() {
//        data.append(try item.attr("data"))
//      }
//    }
//
//    return data
//  }
//
//  public func getAudioTracks(_ url: String) throws -> [BooTrack] {
//    var data = [BooTrack]()
//
//    if let document = try fetchDocument(url) {
//      let items = try document.select("script")
//
//      for item in items.array() {
//        let text = try item.html()
//
//        let index1 = text.find("Play('jw6',")
//        let index2 = text.find("{\"start\":0,")
//
//        if let index1 = index1, let index2 = index2 {
//          let content = String(text[text.index(index1, offsetBy: 10) ... text.index(index2, offsetBy: -1)]).trim()
//          let content2 = content[content.index(content.startIndex, offsetBy: 2) ..< content.index(content.endIndex, offsetBy: -2)]
//          let content3 = content2.replacingOccurrences(of: ",", with: ", ").replacingOccurrences(of: ":", with: ": ")
//
//          if let result = try? content3.data(using: .utf8)!.decoded() as [BooTrack] {
//            data = result
//          }
//        }
//      }
//    }
//
//    return data
//  }
//
//  public func search(_ query: String, page: Int=1) throws -> [[String: String]] {
//    var data = [[String: String]]()
//
//    let url = AudioBooAPI.SiteUrl + "/engine/ajax/search.php"
//
//    if let document = try searchDocument(url, parameters: ["query": query]) {
//      let items = try document.select("a")
//
//      for item in items.array() {
//        let name = try item.text()
//
//        let href = try item.attr("href")
//
//        data.append(["type": "book", "id": href, "name": name])
//      }
//    }
//
//    return data
//  }

  func toDocument(data: Data) throws -> Document? {
    return try data.toDocument(encoding: .windowsCP1251)
  }
}
