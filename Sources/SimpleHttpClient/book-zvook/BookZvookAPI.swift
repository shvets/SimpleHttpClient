import Foundation
import SwiftSoup

open class BookZvookAPI {
  public static let SiteUrl = "http://bookzvuk.ru/"
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

//  public func getPopularBooks() throws -> [[String: String]] {
//    var result = [[String: String]]()
//
//    if let document = try self.getDocument() {
//      let items = try document.select("div[class=textwidget] > div > a")
//
//      for item in items.array() {
//        let name = try item.select("img").attr("alt")
//        let href = try item.attr("href")
//        let thumb = try item.select("img").attr("src")
//
//        result.append(["id": href, "name": name, "thumb": thumb])
//      }
//    }
//
//    return result
//  }

  public func getLetters() throws -> [[String: String]] {
    var result = [[String: String]]()

    if let document = try self.getDocument() {
      let items = try document.select("div[class=textwidget] div[class=newsa_story] b span span a")

      for item in items.array() {
        let name = try item.text()
        let href = try item.attr("href")

        result.append(["id": href, "name": name.uppercased()])
      }
    }

    return result
  }

  public func getAuthorsByLetter(_ url: String) throws -> [Author] {
    var result: [Author] = []

    let path = BookZvookAPI.getURLPathOnly(url, baseUrl: BookZvookAPI.SiteUrl)

    if let document = try self.getDocument(path) {
      result = try AuthorsBuilder().build(document: document)
    }

    return result
  }

  public func getAuthors(_ url: String) throws -> [[String: String]] {
    var list: [[String: String]] = []

    let authors = try getAuthorsByLetter(url)

    for (author) in authors {
      list.append(["name": author.name])
    }

    return list
  }

  public func getAuthorBooks(_ url: String, name: String, page: Int=1, perPage: Int=10) throws -> BookResults {
    var collection = [BookItem]()
    var pagination = Pagination()

    let authors = try getAuthorsByLetter(url)

    for (author) in authors {
      if author.name == name {
        for book in author.books {
          collection.append(["id": book.id, "name": book.title])
        }

        break
      }
    }

    var items: [Any] = []

    for (index, item) in collection.enumerated() {
      if index >= (page-1)*perPage && index < page*perPage {
        items.append(item)
      }
    }

    pagination = buildPaginationData(collection, page: page, perPage: perPage)

    return BookResults(items: collection, pagination: pagination)
  }

  func buildPaginationData(_ data: [Any], page: Int, perPage: Int) -> Pagination {
    let pages = data.count / perPage

    return Pagination(page: page, pages: pages, has_previous: page > 1, has_next: page < pages)
  }

  public func getGenres() throws -> [[String: String]] {
    var result = [[String: String]]()

    if let document = try self.getDocument() {
      let items = try document.select("aside[id=categories-2] div[class=dbx-content] ul li a")

      for item in items.array() {
        let name = try item.text()
        let href = try item.attr("href")

        result.append(["id": href, "name": name])
      }
    }

    return result
  }

  public func getPlaylistUrls(_ url: String) throws -> [String] {
    var result = [String]()

    let path = BookZvookAPI.getURLPathOnly(url, baseUrl: BookZvookAPI.SiteUrl)

    if let document = try self.getDocument(path) {
      let link = try document.select("iframe").attr("src")

      if !link.isEmpty {
        result.append(link)
      }
    }

    return result
  }

  public func getAudioTracks(_ url: String) throws -> [BooTrack] {
    var result = [BooTrack]()

    let path = BookZvookAPI.getURLPathOnly(url, baseUrl: BookZvookAPI.ArchiveUrl)

    if let response = try archiveClient.request(path), let data = response.data,
       let document = try data.toDocument() {
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

  public func getNewBooks(page: Int=1) throws -> BookResults {
    return try getBooks("", page: page)
  }

  public func getGenreBooks(_ path: String, page: Int=1) throws -> BookResults {
    return try getBooks(path, page: page)
  }

  public func getBooks(_ path: String, page: Int=1) throws -> BookResults {
    var collection = [BookItem]()
    var pagination = Pagination()

    let pagePath = getPagePath(path: path, page: page)

    if let document = try self.getDocument(pagePath) {
      let items = try document.select("div[id=main-col] div[id=content] article")

      for item in items.array() {
        collection.append(try self.getBook(item))
      }

      pagination = try self.extractPaginationData(document: document, path: pagePath, page: page)
    }

    return BookResults(items: collection, pagination: pagination)
  }

  public func search(_ query: String, page: Int=1) throws -> BookResults {
    var collection = [BookItem]()
    var pagination = Pagination()

    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    let path = getPagePath(path: "", page: page)

    let content = "s=\(encodedQuery)"
    let body = content.data(using: .utf8, allowLossyConversion: false)

    if let response = try apiClient.request(path, method: .post, body: body), let data = response.data,
       let document = try data.toDocument() {
      let items = try document.select("div[id=main-col] div[id=content] article")

      for item in items.array() {
        collection.append(try self.getBook(item))
      }

      pagination = try self.extractPaginationData(document: document, path: path, page: page)
    }

    return BookResults(items: collection, pagination: pagination)
  }

  private func getBook(_ item: Element) throws -> [String: String] {
    let link = try item.select("header div h2 a")

    let thumb = try item.select("div[class=entry-container fix] div p img").attr("src")

    let description = try item.select("div[class=entry-container fix] div").text()

    let href = try link.attr("href")

    let name = try link.text().trim()
      .replacingOccurrences(of: "(Аудиокнига онлайн)", with: "")
      .replacingOccurrences(of: "(Аудиоспектакль онлайн)", with: "(спектакль)")
      .replacingOccurrences(of: "(Audiobook online)", with: "")

    return ["type": "book", "id": href, "name": name, "thumb": thumb, "description": description]
  }

  func extractPaginationData(document: Document, path: String, page: Int) throws ->  Pagination {
    var pages = 1

    let paginationRoot = try document.select("div[class=page-nav fix] div[class=wp-pagenavi]")

    if paginationRoot.size() > 0 {
      let paginationBlock = paginationRoot.get(0)

      let items = try paginationBlock.select("span[class=pages]").array()

      if items.count == 1 {
        let text = try items[0].text()

        if let index1 = text.find("из") {
          let index2 = text.index(index1, offsetBy: 3)

          pages = Int(String(text[index2..<text.endIndex]).replacingOccurrences(of: " ", with: ""))!
        }
      }
    }

    return Pagination(page: page, pages: pages, has_previous: page > 1, has_next: page < pages)
  }

  public func getDocument(_ path: String = "") throws -> Document? {
    var document: Document? = nil

    if let response = try apiClient.request(path), let data = response.data {
      document = try data.toDocument()
    }

    return document
  }
}
