import Foundation
import SwiftSoup

open class KinoKongAPI {
  public static let SiteUrl = "https://kinokong.se"

  let UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36"

  let apiClient = ApiClient(URL(string: SiteUrl)!)

  public static func getURLPathOnly(_ url: String, baseUrl: String) -> String {
    return String(url[baseUrl.index(url.startIndex, offsetBy: baseUrl.count)...])
  }

  func getHeaders(_ referer: String="") -> [HttpHeader] {
    var headers: [HttpHeader] = []
    headers.append(HttpHeader(field: "User-Agent", value: UserAgent))
    headers.append(HttpHeader(field: "Host", value: KinoKongAPI.SiteUrl.replacingOccurrences(of: "https://", with: "")))
    headers.append(HttpHeader(field: "Upgrade-Insecure-Requests", value: "1"))

    if !referer.isEmpty {
      headers.append(HttpHeader(field: "Referer", value: referer))
    }
    else {
      headers.append(HttpHeader(field: "Referer", value: KinoKongAPI.SiteUrl))
    }

    return headers
  }

  public func getDocument(_ path: String = "", queryItems: [URLQueryItem] = []) throws -> Document? {
    var document: Document? = nil

    if let response = try apiClient.request(path, queryItems: queryItems),
       let data = response.body {
      document = try data.toDocument(encoding: .windowsCP1251)
    }

    return document
  }

  func getPagePath(_ path: String, page: Int=1) -> String {
    if page == 1 {
      return path
    }
    else {
      return "\(path)page/\(page)/"
    }
  }

  public func available() throws -> Bool {
    if let document = try getDocument() {
      return try document.select("div[id=container]").size() > 0
    }
    else {
      return false
    }
  }

  public func getAllMovies(page: Int=1) throws -> BookResults {
    return try getMovies("/film/", page: page)
  }

  public func getNewMovies(page: Int=1) throws -> BookResults {
    return try getMovies("/film/2019", page: page)
  }

  public func getAllSeries(page: Int=1) throws -> BookResults {
    return try getMovies("/series/", page: page)
  }

  public func getAnimations(page: Int=1) throws -> BookResults {
    return try getMovies("/cartoons/", page: page)
  }

  public func getAnime(page: Int=1) throws -> BookResults {
    return try getMovies("/animes/", page: page)
  }

  public func getTvShows(page: Int=1) throws -> BookResults {
    return try getMovies("/documentary/", page: page)
  }

  public func getMovies(_ path: String, page: Int=1) throws -> BookResults {
    var collection = [BookItem]()
    var pagination = Pagination()

    let pagePath = getPagePath(path, page: page)

    if let document = try getDocument(pagePath) {
      let items = try document.select("div[class=owl-item]")

      for item: Element in items.array() {
        var href = try item.select("div[class=item] span[class=main-sliders-bg] a").attr("href")
        let name = try item.select("h2[class=main-sliders-title] a").text()
        let thumb = try KinoKongAPI.SiteUrl +
          item.select("div[class=main-sliders-shadow] span[class=main-sliders-bg] ~ img").attr("src")

        let seasonNode = try item.select("div[class=main-sliders-shadow] div[class=main-sliders-season]").text()

        if href.find(KinoKongAPI.SiteUrl) != nil {
          let index = href.index(href.startIndex, offsetBy: KinoKongAPI.SiteUrl.count)

          href = String(href[index ..< href.endIndex])
        }

        let type = seasonNode.isEmpty ? "movie" : "serie"

        collection.append(["id": href, "name": name, "thumb": thumb, "type": type])
      }

      if items.size() > 0 {
        pagination = try extractPaginationData(document, page: page)
      }
    }

    return BookResults(items: collection, pagination: pagination)
  }

  func getMoviesByRating(page: Int=1) throws -> BookResults {
    return try getMoviesByCriteriaPaginated("rating", page: page)
  }

  func getMoviesByViews(page: Int=1) throws -> BookResults {
    return try getMoviesByCriteriaPaginated("views", page: page)
  }

  func getMoviesByComments(page: Int=1) throws -> BookResults {
    return try getMoviesByCriteriaPaginated("comments", page: page)
  }

  public func getMoviesByCriteriaPaginated(_ mode: String, page: Int=1, perPage: Int=25) throws -> BookResults {
    var queryItems: [URLQueryItem] = []
    queryItems.append(URLQueryItem(name: "do", value: "top"))
    queryItems.append(URLQueryItem(name: "mode", value: mode))

    let collection = try getMoviesByCriteria(queryItems: queryItems)

    var items: [Any] = []

    for (index, item) in collection.enumerated() {
      if index >= (page-1)*perPage && index < page*perPage {
        items.append(item)
      }
    }

    let pagination = buildPaginationData(collection, page: page, perPage: perPage)

    return BookResults(items: collection, pagination: pagination)
  }

  func getMoviesByCriteria(queryItems: [URLQueryItem]) throws ->  [BookItem] {
    var data =  [BookItem]()

    if let document = try getDocument(queryItems: queryItems) {
      let items = try document.select("div[id=dle-content] div div table tr")

      for item: Element in items.array() {
        let link = try item.select("td a")

        if !link.array().isEmpty {
          var href = try link.attr("href")

          let index = href.index(href.startIndex, offsetBy: KinoKongAPI.SiteUrl.count)

          href = String(href[index ..< href.endIndex])

          let name = try link.text().trim()

          let tds = try item.select("td").array()

          let rating = try tds[tds.count-1].text()

          data.append(["id": href, "name": name, "rating": rating, "type": "rating"])
        }
      }
    }

    return data
  }

  public func getTags() throws -> [BookItem] {
    var data = [BookItem]()

    if let document = try getDocument("kino-podborka.html") {
      let items = try document.select("div[class=podborki-item-block]")

      for item: Element in items.array() {
        let link = try item.select("a")
        let img = try item.select("a span img")
        let title = try item.select("a span[class=podborki-title]")
        let href = try link.attr("href")

        var thumb = try img.attr("src")

        if thumb.find(KinoKongAPI.SiteUrl) == nil {
          thumb = KinoKongAPI.SiteUrl + thumb
        }

        let name = try title.text()

        data.append(["id": href, "name": name, "thumb": thumb, "type": "movie"])
      }
    }

    return data
  }

  func buildPaginationData(_ data: [BookItem], page: Int, perPage: Int) ->Pagination {
    let pages = data.count / perPage

    return Pagination(page: page, pages: pages, has_previous: page > 1, has_next: page < pages)
  }

  func getSeries(_ path: String, page: Int=1) throws -> BookResults {
    return try getMovies(path, page: page)
  }

  public func getUrls(_ path: String) throws -> [String] {
    var urls: [String] = []

    if let document = try getDocument(path) {
      let items = try document.select("script")

      for item: Element in items.array() {
        let text0 = try item.html()
        let text = text0.replacingOccurrences(of: ",file:", with: ", file:")

        if !text.isEmpty {
          let index1 = text.find("\", file:\"")
          let index2 = text.find("\"});")

          if let startIndex = index1, let endIndex = index2 {
            urls = text[text.index(startIndex, offsetBy: 8) ..< endIndex].components(separatedBy: ",")

            break
          }
          else {
            let index1 = text.find("\", file:\"")
            let index2 = text.find("\",st:")

            if let startIndex = index1, let endIndex = index2 {
              urls = text[text.index(startIndex, offsetBy: 8) ..< endIndex].components(separatedBy: ",")

              break
            }
          }
        }
      }
    }

    var newUrls: [String] = []

    for url in urls {
      if !url.hasPrefix("cuid:") {
        let newUrl = url.replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: "[720]", with: "")
            .replacingOccurrences(of: "[480]", with: "")

          newUrls.append(newUrl)
      }
    }

    return newUrls.reversed()
  }

  public func getSeriePlaylistUrl(_ path: String) throws -> String {
    var url = ""

    if let document = try getDocument(path) {
      let items = try document.select("script")

      for item: Element in items.array() {
        let text = try item.html()

        if !text.isEmpty {
          let index1 = text.find("pl:")

          if let startIndex = index1 {
            let text2 = String(text[startIndex ..< text.endIndex])

            let index2 = text2.find("\",")

            if let endIndex = index2 {
              url = String(text2[text2.index(text2.startIndex, offsetBy:4) ..< endIndex])

              break
            }
          }
        }
      }
    }

    return url
  }

  public func getMetadata(_ url: String) -> [String: String] {
    var data = [String: String]()

    let groups = url.components(separatedBy: ".")

    if (groups.count > 1) {
      let text = groups[groups.count-2]

      let pattern = "(\\d+)p_(\\d+)"

      do {
        let regex = try NSRegularExpression(pattern: pattern)

        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))

        if let width = getMatched(text, matches: matches, index: 1) {
          data["width"] = width
        }

        if let height = getMatched(text, matches: matches, index: 2) {
          data["height"] = height
        }
      }
      catch {
        print("Error in regular expression.")
      }

    }

    return data
  }

  func getMatched(_ link: String, matches: [NSTextCheckingResult], index: Int) -> String? {
    var matched: String?

    let match = matches.first

    if let match = match, index < match.numberOfRanges {
      let capturedGroupIndex = match.range(at: index)

      let index1 = link.index(link.startIndex, offsetBy: capturedGroupIndex.location)
      let index2 = link.index(index1, offsetBy: capturedGroupIndex.length-1)

      matched = String(link[index1 ... index2])
    }

    return matched
  }

  public func getGroupedGenres() throws -> [String: [BookItem]] {
    var data = [String: [BookItem]]()

    if let document = try getDocument() {
      let items = try document.select("div[id=header] div div div ul li")

      for item: Element in items.array() {
        let hrefLink = try item.select("a")
        let genresNode1 = try item.select("span em a")
        let genresNode2 = try item.select("span a")

        var href = try hrefLink.attr("href")

        if href == "#" {
          href = "top"
        }
        else {
          href = String(href[href.index(href.startIndex, offsetBy: 1) ..< href.index(href.endIndex, offsetBy: -1)])
        }

        var genresNode: Elements?

        if !genresNode1.array().isEmpty {
          genresNode = genresNode1
        }
        else {
          genresNode = genresNode2
        }

        if let genresNode = genresNode, !genresNode.array().isEmpty {
          data[href] = []

          for genre in genresNode {
            let path = try genre.attr("href")
            let name = try genre.text()

            if !["/kino-recenzii/", "/news-kino/"].contains(path) {
              data[href]!.append(["id": path, "name": name])
            }
          }
        }
      }
    }

    return data
  }

  public func search(_ query: String, page: Int=1, perPage: Int=15) throws -> BookResults {
    var collection = [BookItem]()
    var pagination = Pagination()

    var queryItems: [URLQueryItem] = []
    queryItems.append(URLQueryItem(name: "do", value: "search"))

    let path = "/index.php"

    var content = "subaction=search&" + "search_start=\(page)&" + "full_search=0&" +
      "story=\(query.windowsCyrillicPercentEscapes())"

    if page > 1 {
      content += "&result_from=\(page * perPage + 1)"
    }
    else {
      content += "&result_from=1"
    }

    let body = content.data(using: .utf8, allowLossyConversion: false)

    if let response = try apiClient.request(path, method: .post, queryItems: queryItems,
      headers: getHeaders(), body: body),
       let data = response.body,
       let document = try data.toDocument(encoding: .windowsCP1251) {
      let items = try document.select("div[class=owl-item]")

      for item: Element in items.array() {
        var href = try item.select("div[class=item] span[class=main-sliders-bg] a").attr("href")
        let name = try item.select("div[class=main-sliders-title] a").text()
        let thumb = try item.select("div[class=item] span[class=main-sliders-bg] img").attr("src")
        //try item.select("div[class=main-sliders-shadow] span[class=main-sliders-bg] ~ img").attr("src")

        let seasonNode = try item.select("div[class=main-sliders-shadow] span[class=main-sliders-season]").text()

        if href.find(KinoKongAPI.SiteUrl) != nil {
          let index = href.index(href.startIndex, offsetBy: KinoKongAPI.SiteUrl.count)

          href = String(href[index ..< href.endIndex])
        }

        var type = seasonNode.isEmpty ? "movie" : "serie"

        if name.contains("Сезон") || name.contains("сезон") {
          type = "serie"
        }

        collection.append(["id": href, "name": name, "thumb": thumb, "type": type])
      }

      if items.size() > 0 {
        pagination = try extractPaginationData(document, page: page)
      }
    }

    return BookResults(items: collection, pagination: pagination)
  }

  func extractPaginationData(_ document: Document, page: Int) throws -> Pagination {
    var pages = 1

    let paginationRoot = try document.select("div[class=basenavi] div[class=navigation]")

    if !paginationRoot.array().isEmpty {
      let paginationNode = paginationRoot.get(0)

      let links = try paginationNode.select("a").array()

      if let number = Int(try links[links.count-1].text()) {
        pages = number
      }
    }

    return Pagination(page: page, pages: pages, has_previous: page > 1, has_next: page < pages)
  }

  public func getSeasons(_ playlistUrl: String, path: String = "") throws -> [Season] {
    var list: [Season] = []

    let newPath = KinoKongAPI.getURLPathOnly(playlistUrl, baseUrl: KinoKongAPI.SiteUrl)

    if let response = try apiClient.request(newPath, headers: getHeaders(KinoKongAPI.SiteUrl + "/" + path)),
       let data = response.body,
       let content = String(data: data, encoding: .windowsCP1251) {

      if !content.isEmpty {
        if let index = content.find("{\"playlist\":") {
          let playlistContent = content[index ..< content.endIndex]

          if let localizedData = playlistContent.data(using: .windowsCP1251) {
            if let result = apiClient.decode(localizedData, to: PlayList.self) {
              for item in result.playlist {
                list.append(Season(comment: item.comment, playlist: buildEpisodes(item.playlist)))
              }
            }
            else if let result = apiClient.decode(localizedData, to: SingleSeasonPlayList.self) {
              list.append(Season(comment: "Сезон 1", playlist: buildEpisodes(result.playlist)))
            }
          }
        }
      }
    }

    return list
  }

  func buildEpisodes(_ playlist: [Episode]) -> [Episode] {
    var episodes: [Episode] = []

    for item in playlist {
      let filesStr = item.file.components(separatedBy: ",")

      var files: [String] = []

      for item in filesStr {
        if !item.isEmpty {
          files.append(item)
        }
      }

      episodes.append(Episode(comment: item.comment, file: item.file, files: files))
    }

    return episodes
  }

  func getEpisodeUrl(url: String, season: String, episode: String) -> String {
    var episodeUrl = url

    if !season.isEmpty {
      episodeUrl = "\(url)?season=\(season)&episode=\(episode)"
    }

    return episodeUrl
  }

  func getSoundtrackPlaylistUrl(_ path: String) throws -> String {
    return try getSeriePlaylistUrl(path)
  }

  func getSoundtracks(_ playlistUrl: String) throws -> [Season] {
    return try getSeasons(playlistUrl)
  }
}
