import Foundation

import SwiftSoup

open class KinoGoAPI {
  public static let SiteUrl = "https://kinogo.by"
  let UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"

  let apiClient = ApiClient(URL(string: SiteUrl)!)

  public static func getURLPathOnly(_ url: String, baseUrl: String) -> String {
    return String(url[baseUrl.index(url.startIndex, offsetBy: baseUrl.count)...])
  }

  func getHeaders(_ referer: String="") -> [HttpHeader] {
    var headers: [HttpHeader] = []
    headers.append(HttpHeader(field: "User-Agent", value: UserAgent))

    if !referer.isEmpty {
      headers.append(HttpHeader(field: "Referer", value: referer))
    }

    return headers
  }

  public func getDocument(_ path: String = "") throws -> Document? {
    var document: Document? = nil

    if let response = try apiClient.request(path), let data = response.body {
      document = try data.toDocument(encoding: .windowsCP1251)
    }

    return document
  }

  public func available() throws -> Bool {
    if let document = try getDocument() {
      return try document.select("div[class=wrapper]").size() > 0
    }
    else {
      return false
    }
  }

  public func getCookie(url: String) throws -> String? {
    let path = KinoGoAPI.getURLPathOnly(url, baseUrl: KinoGoAPI.SiteUrl)

    let response = try apiClient.request(path)

    return response?.response?.allHeaderFields["Set-Cookie"] as? String
  }

  func getPagePath(_ path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page/\(page)/"
    }
  }

  public func getCategoriesByTheme() throws -> [[String: String]] {
    var categories = try getAllCategories()["Категории"]!

    categories.remove(at: categories.index(categories.endIndex, offsetBy: -1))

    return categories
  }

  public func getCategoriesByCountry() throws -> [[String: String]] {
    return try getAllCategories()["По странам"]!
  }

  public func getCategoriesByYear() throws -> [[String: String]] {
    return try getAllCategories()["По году"]!
  }

  public func getCategoriesBySerie() throws -> [[String: String]] {
    return try getAllCategories()["Сериалы"]!
  }

  public func getAllCategories() throws -> [String: [[String: String]]] {
    var data = [String: [[String: String]]]()

    if let document = try getDocument() {
      let items = try document.select("div[class=miniblock] div[class=mini]")

      for item: Element in items.array() {
        let groupName = try item.select("i").text()

        var list = [[String: String]]()

        let links = try item.select("a")

        for item2: Element in links.array() {
          let href = try item2.attr("href")
          var name = try item2.text()

          if let nextSibling = item2.nextSibling(),
            let firstSibling = nextSibling.getChildNodes().first as? TextNode {
              name += " \(firstSibling.text())"
          }

          list.append(["id": KinoGoAPI.SiteUrl + href, "name": name])
        }

        data[groupName] = list
      }
    }

    return data
  }

  public func getAllMovies(page: Int=1) throws -> BookResults {
    return try getMovies("/", page: page)
  }

  public func getPremierMovies(page: Int=1) throws -> BookResults {
    return try getMovies("/film/premiere/", page: page)
  }

  public func getLastMovies(page: Int=1) throws -> BookResults {
    return try getMovies("/film/", page: page)
  }

  public func getAllSeries(page: Int=1) throws ->BookResults {
    let result = try getMovies("/serial/", page: page, serie: true)

    return BookResults(items: try sanitizeNames(result.items), pagination: result.pagination)
  }

  private func sanitizeNames(_ movies: Any) throws -> [BookItem] {
    var newMovies = [BookItem]()

    for var movie in movies as! [[String: String]] {
      let pattern = "(\\s*\\(\\d{1,2}-\\d{1,2}\\s*(С|с)езон\\))"

      let regex = try NSRegularExpression(pattern: pattern)

      if let name = movie["name"] {
        let correctedName = regex.stringByReplacingMatches(in: name, options: [], range: NSMakeRange(0, name.count), withTemplate: "")

        movie["name"] = correctedName

        newMovies.append(movie)
      }
    }

    return newMovies
  }

  public func getAnimations(page: Int=1) throws -> BookResults {
    return try getMovies("/mult/", page: page)
  }

  public func getAnime(page: Int=1) throws -> BookResults {
    return try getMovies("/anime/", page: page)
  }

  public func getTvShows(page: Int=1) throws -> BookResults {
    let result = try getMovies("/tv/", page: page, serie: true)

    return BookResults(items: try sanitizeNames(result.items), pagination: result.pagination)
  }

  public func getMoviesByCategory(category: String, page: Int=1) throws -> BookResults {
    let encoded = category.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    return try getMovies("\(encoded)", page: page)
  }

  public func getMoviesByCountry(country: String, page: Int=1) throws -> BookResults {
    let encoded = country.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

    return try getMovies("\(encoded)", page: page)
  }

  public func getMoviesByYear(year: Int, page: Int=1) throws -> BookResults {
    return try getMovies("/tags/\(year)/", page: page)
  }

  public func getMovies(_ path: String, page: Int=1, serie: Bool=false) throws -> BookResults {
    var collection = [BookItem]()
    var pagination = Pagination()

    let pagePath = getPagePath(path, page: page)

    if let document = try getDocument(pagePath) {
      let content = try document.select("div[id=dle-content]")

      if content.array().count > 0 {
        let items = try content.get(0).getElementsByClass("shortstory")

        for item: Element in items.array() {
          let href = try item.select("div[class=shortstorytitle] h2 a").attr("href")
          let name = try item.select("div[class=shortstorytitle] h2 a").text()
          let thumb = try item.select("div[class=shortimg] a img").first()!.attr("src")

          var type: String

          if name.contains("Сезон") || name.contains("сезон") {
            type = "serie"
          }
          else {
            type = serie ? "serie" : "movie"
          }

          collection.append(["id": href, "name": name, "thumb": KinoGoAPI.SiteUrl + thumb, "type": type])
        }

        if items.size() > 0 {
          pagination = try extractPaginationData(document, page: page)
        }
      }
    }

    return BookResults(items: collection, pagination: pagination)
  }

  public func getUrls(_ path: String) throws -> [String] {
    var urls: [String] = []

    if let document = try getDocument(path) {
      let items = try document.select("script")

      for item: Element in items.array() {
        let text = try item.html()

        if !text.isEmpty {
          let index1 = text.find("\"file\"  : ")

          if let startIndex = index1 {
            let text2 = String(text[startIndex..<text.endIndex])

            let text3 = text2

            //.replacingOccurrences(of: "[480,720]", with: "720")

            let index2 = text3.find("\",")

            if let endIndex = index2 {
              let text4 = text3[text.index(text3.startIndex, offsetBy: 11) ..< endIndex]

              let text5 = text4.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)

              let text6 = String(text5[text5.startIndex ..< text5.index(text5.endIndex, offsetBy: -2)])

              urls = File(comment: "", file: text6).urls()
                //text6.components(separatedBy: ",")

              break
            }
          }
        }
      }
    }

    var found720 = false

    for url in urls {
      if url.find("720.mp4") != nil {
        found720 = true
      }
    }

    if !found720 && urls.count > 0 {
      urls[urls.count-1] = urls[urls.count-1].replacingOccurrences(of: "480", with: "720")
    }

    return urls.reversed()
  }

//  public func getSeasonPlaylistUrl(_ path: String) throws -> String {
//    var url = ""
//
//    if let document = try getDocument(path) {
//      let items = try document.select("script")
//
//      for item: Element in items.array() {
//        let text = try item.html()
//
//        if !text.isEmpty {
//          let index1 = text.find("pl:")
//
//          if let startIndex = index1 {
//            let text2 = String(String(text[startIndex ..< text.endIndex]))
//
//            let index2 = text2.find("\",st:")
//
//            if let endIndex = index2 {
//              url = String(text2[text2.index(text2.startIndex, offsetBy:4) ..< endIndex])
//
//              break
//            }
//          }
//        }
//      }
//    }
//
//    return url
//  }

  public func search(_ query: String, page: Int=1, perPage: Int=10) throws -> BookResults {
    var collection = [BookItem]()
    var pagination = Pagination()

    var queryItems: [URLQueryItem] = []
    queryItems.append(URLQueryItem(name: "do", value: "search"))

    let path = "/index.php"

    var content = "do=search&" + "subaction=search&" + "search_start=\(page)&" + "full_search=0&" +
      "story=\(query.windowsCyrillicPercentEscapes())"

    if page > 1 {
      content += "&result_from=\(page * perPage + 1)"
    }
    else {
      content += "&result_from=1"
    }

    let body = content.data(using: .utf8, allowLossyConversion: false)

    if let response = try apiClient.request(path, method: .post,
      queryItems: queryItems,
      headers: getHeaders(KinoGoAPI.SiteUrl + "/"), body: body),
       let data = response.body,
       let document = try data.toDocument(encoding: .windowsCP1251) {
      let items = try document.select("div[class=shortstory]")

      for item: Element in items.array() {
        let title = try item.select("div[class=shortstorytitle]")
        let shortimg = try item.select("div[class=shortimg]")

        let name = try title.text()

        let href = try shortimg.select("div a").attr("href")

        let description = try shortimg.select("div div").text()
        let thumb = try shortimg.select("img").first()!.attr("src")
        var type = "movie"

        if name.contains("Сезон") || name.contains("сезон") {
          type = "serie"
        }

        collection.append(["id": href, "name": name, "description": description, 
                           "thumb": KinoGoAPI.SiteUrl + thumb, "type": type])
      }

      if items.size() > 0 {
        pagination = try extractPaginationData(document, page: page)
      }
    }

    return BookResults(items: collection, pagination: pagination)
  }

  func extractPaginationData(_ document: Document, page: Int) throws -> Pagination {
    var pages = 1

    let paginationRoot = try document.select("div[class=bot-navigation]")

    if !paginationRoot.array().isEmpty {
      let paginationNode = paginationRoot.get(0)

      let links = try paginationNode.select("a").array()

      if let number = Int(try links[links.count-2].text()) {
        pages = number
      }
    }

    return Pagination(page: page, pages: pages, has_previous: page > 1, has_next: page < pages)
  }

  public func getSeasons(_ path: String, _ name: String?=nil, _ thumb: String?=nil) throws -> [Season] {
    var list: [Season] = []

    if let document = try getDocument(path) {
      let items = try document.select("script")

      for item: Element in items.array() {
        let text = try item.html()

        if !text.isEmpty {
          let index1 = text.find("\"file\" : [{")

          if let startIndex = index1 {
            let text2 = String(text[startIndex..<text.endIndex])

            let text3 = text2

            let index2 = text3.find("}],")

            if let endIndex = index2 {
              let text4 = text3[text.index(text3.startIndex, offsetBy: 9) ..< endIndex]

              let text5 = text4.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .newlines)

              let text6 = String(text5[text5.startIndex ..< text5.index(text5.endIndex, offsetBy: 0)] + "}]")

              let playlistContent = text6.replacingOccurrences(of: "'", with: "\"")
//                .replacingOccurrences(of: ":", with: ": ")
                .replacingOccurrences(of: ",", with: ", ")

              if let localizedData = playlistContent.data(using: .utf8) {
                if let seasons = try? localizedData.decoded() as [Season] {
                  for season in seasons {
                    list.append(season)
                  }
                }
                else if let result = try? localizedData.decoded() as [Episode] {
                  let comment = (name != nil) ? name! : ""

                  var result2: [File] = []

                  for r in result {
                    result2.append(File(comment: r.title, file: r.file))
                  }

                  let season = Season(comment: comment, folder: result2)

                  list.append(season)
                }
              }
              break
            }
          }
        }
      }
    }

    return list
  }
}
