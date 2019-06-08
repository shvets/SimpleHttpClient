import Foundation
import RxSwift

open class EtvnetAPI {
  public static let PER_PAGE = 15

  public static let ApiUrl = "https://secure.etvnet.com/api/v3.0/"
  public static let AuthUrl = "https://accounts.etvnet.com/auth/oauth/"

  public static let TimeShift = [
    "0": 0,  // Moscow
    "1": 2,  // Berlin
    "2": 3,  // London
    "3": 8,  // New York
    "4": 9,  // Chicago
    "5": 10, // Denver
    "6": 11  // Los Angeles
  ]

  public static let Topics = ["etvslider/main", "newmedias", "best", "top", "newest", "now_watched", "recommend"]

  let apiClient = EtvnetApiClient(EtvnetAPI.ApiUrl, authUrl: EtvnetAPI.AuthUrl)

  public init(config: ConfigFile<String>) {
    apiClient.loadConfig(config: config)
  }

  public func getChannels(today: Bool = false) -> [Name] {
    let path = "video/channels.json"

    let params: [URLQueryItem] = [
      URLQueryItem(name: "today", value: String(today))
    ]

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .names(let channels) = response.value.data {
        return channels
      }
    }

    return []
  }

  public func getArchive(genre: Int? = nil, channelId: Int? = nil, perPage: Int=PER_PAGE, page: Int=1) ->
    PaginatedMediaData? {
    var path: String

    if channelId != nil && genre != nil {
      path = "video/media/channel/\(channelId!)/archive/\(genre!).json"
    }
    else if genre != nil {
      path = "video/media/archive/\(genre!).json"
    }
    else if channelId != nil {
      path = "video/media/channel/\(channelId!)/archive.json"
    }
    else {
      path = "video/media/archive.json"
    }

    var params: [URLQueryItem] = []
    params.append(URLQueryItem(name: "per_page", value: String(perPage)))
    params.append(URLQueryItem(name: "page", value: String(page)))

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .paginatedMedia(let value) = response.value.data {
        return value
      }
    }

    return nil
  }

  public func getGenres(parentId: String? = nil, today: Bool=false, channelId: String? = nil, format: String? = nil) ->
    [Genre] {
    let path = "video/genres.json"

    var params: [URLQueryItem] = []

    if let parentId = parentId {
      params.append(URLQueryItem(name: "parent", value: parentId))
    }

    if today {
      params.append(URLQueryItem(name: "today", value: "yes"))
    }

    if let channelId = channelId {
      params.append(URLQueryItem(name: "channel", value: channelId))
    }

    if let format = format {
      params.append(URLQueryItem(name: "format", value: format))
    }

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .genres(let genres) = response.value.data {
        // regroup genres

        var regrouped = [Genre]()

        regrouped.append(genres[0])
        regrouped.append(genres[1])
        regrouped.append(genres[5])
        regrouped.append(genres[9])

        regrouped.append(genres[7])
        regrouped.append(genres[2])
        regrouped.append(genres[3])
        regrouped.append(genres[4])

        regrouped.append(genres[6])
        regrouped.append(genres[8])
        regrouped.append(genres[10])
        regrouped.append(genres[11])

        regrouped.append(genres[12])
        // regrouped.append(genres[13])
        regrouped.append(genres[13])
        // regrouped.append(genres[15])

        return regrouped
      }
    }

    return []
  }

  public func getGenre(_ genres: [Genre], name: String) -> Int? {
    var found: Int?

    for genre in genres {
      if genre.name == name {
        found = genre.id

        break
      }
    }

    return found
  }

//  public func getBlockbusters(perPage: Int=PER_PAGE, page: Int=1) -> Observable<PaginatedMediaData?> {
////    let genres = getGenres()
////
////    let genre = getGenre(genres, name: "Блокбастеры")
//
//    return getArchive(genre: 217, perPage: perPage, page: page)
//  }

//  public func getBlockbusters(perPage: Int=PER_PAGE, page: Int=1) -> Observable<PaginatedMediaData?> {
//    let genres = getGenres()
//
//    let genre = getGenre(genres, name: "Блокбастеры")
//
//    return getArchive2(genre: genre, perPage: perPage, page: page)
//  }

//  public func getCoolMovies(perPage: Int=PER_PAGE, page: Int=1) -> Observable<PaginatedMediaData?> {
//    return getArchive(channelId: 158, perPage: perPage, page: page)
//  }

  public func search(_ query: String, perPage: Int=PER_PAGE, page: Int=1, dir: String? = nil) -> PaginatedMediaData? {
    var newDir = dir

    if newDir == nil {
      newDir = "desc"
    }

    let path = "video/media/search.json"

    var params: [URLQueryItem] = []

    params.append(URLQueryItem(name: "q", value: query))
    params.append(URLQueryItem(name: "per_page", value: String(perPage)))
    params.append(URLQueryItem(name: "page", value: String(page)))
    params.append(URLQueryItem(name: "dir", value: dir))

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .paginatedMedia(let value) = response.value.data {
        return value
      }
    }

    return nil
  }

  public func getNewArrivals(genre: String? = nil, channelId: String? = nil, perPage: Int=PER_PAGE, page: Int=1) ->
    PaginatedMediaData? {
    var path: String

    if channelId != nil && genre != nil {
      path = "video/media/channel/\(channelId!)/new_arrivals/\(genre!).json"
    }
    else if genre != nil {
      path = "video/media/new_arrivals/\(genre!).json"
    }
    else if channelId != nil {
      path = "video/media/channel/\(channelId!)/new_arrivals.json"
    }
    else {
      path = "video/media/new_arrivals.json"
    }

    var params: [URLQueryItem] = []
    params.append(URLQueryItem(name: "per_page", value: String(perPage)))
    params.append(URLQueryItem(name: "page", value: String(page)))

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .paginatedMedia(let value) = response.value.data {
        return value
      }
    }

    return nil
  }

  public func getHistory(perPage: Int=PER_PAGE, page: Int=1) -> PaginatedMediaData? {
    let path = "video/media/history.json"

    var params: [URLQueryItem] = []
    params.append(URLQueryItem(name: "per_page", value: String(perPage)))
    params.append(URLQueryItem(name: "page", value: String(page)))

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .paginatedMedia(let value) = response.value.data {
        return value
      }
    }

    return nil
  }

  public func getLiveChannelUrl(_ channelId: Int, format: String="mp4", mediaProtocol: String="hls",
                                bitrate: String? = nil, otherServer: String? = nil, offset: String? = nil) -> [String: String] {
    return getUrl(0, format: format, mediaProtocol: mediaProtocol, bitrate: bitrate, otherServer: otherServer,
      offset: offset, live: true, channelId: channelId, preview: false)
  }

  public func getUrl(_ mediaId: Int, format: String="mp4", mediaProtocol: String="hls", bitrate: String? = nil,
                     otherServer: String? = nil, offset: String? = nil, live: Bool=false,
                     channelId: Int? = nil, preview: Bool=false) -> [String: String] {
    var newFormat = format
    var newMediaProtocol: String? = mediaProtocol

    if format == "zixi" {
      newFormat = "mp4"
    }

    let path: String

    var params: [URLQueryItem] = []

    params.append(URLQueryItem(name: "format", value: newFormat))

    if let bitrate = bitrate {
      params.append(URLQueryItem(name: "bitrate", value: bitrate))
    }

    if let otherServer = otherServer {
      params.append(URLQueryItem(name: "other_server", value: otherServer))
    }

    if live {
      path = "video/live/watch/\(channelId!).json"

      if let offset = offset {
        params.append(URLQueryItem(name: "offset", value: offset))
      }
    }
    else {
      if format == "wmv" {
        newMediaProtocol = nil
      }

      if newFormat == "mp4" && mediaProtocol != "hls" {
        newMediaProtocol = "rtmp"
      }

      let link_type: String

      if preview {
        link_type = "preview"
      }
      else {
        link_type = "watch"
      }

      path = "video/media/\(mediaId)/\(link_type).json"

      if let newMediaProtocol = newMediaProtocol {
        params.append(URLQueryItem(name: "protocol", value: newMediaProtocol))
      }
    }

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .url(let value) = response.value.data {
        var urlInfo = [String: String]()

        urlInfo["url"] = value.url
        urlInfo["format"] =  newFormat

        if newMediaProtocol != nil {
          urlInfo["protocol"] = newMediaProtocol
        }

        return urlInfo
      }
    }

    return [:]
  }

  public func getChildren(_ mediaId: Int, perPage: Int=PER_PAGE, page: Int=1, dir: String?=nil) -> PaginatedChildrenData? {
    let path = "video/media/\(mediaId)/children.json"

    var params: [URLQueryItem] = []
    params.append(URLQueryItem(name: "per_page", value: String(perPage)))
    params.append(URLQueryItem(name: "page", value: String(page)))
    params.append(URLQueryItem(name: "dir", value: dir))

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .paginatedChildren(let value) = response.value.data {
        return value
      }
    }

    return nil
  }

  public func getBookmarks(folder: String? = nil, perPage: Int=PER_PAGE, page: Int=1) -> PaginatedBookmarksData? {
    var path: String

    if folder != nil {
      path = "video/bookmarks/folders/\(folder!)/items.json"
    }
    else {
      path = "video/bookmarks/items.json"
    }

    var params: [URLQueryItem] = []
    params.append(URLQueryItem(name: "per_page", value: String(perPage)))
    params.append(URLQueryItem(name: "page", value: String(page)))

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .paginatedBookmarks(let value) = response.value.data {
        return value
      }
    }

    return nil
  }

//  public func getFolders(perPage: Int=PER_PAGE) -> JSON {
//    let url = buildUrl(path: "video/bookmarks/folders.json")
//
//    let response = fullRequest0(path: url)
//
//    return JSON(data: response!.data!)
//  }

  public func getBookmark(id: Int) -> Media? {
    let path = "video/bookmarks/items/\(id).json"

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self) {
      if case .paginatedBookmarks(let value) = response.value.data {
        return value.bookmarks[0]
      }
    }

    return nil
  }

  public func addBookmark(id: Int) -> Bool {
    let path = "video/bookmarks/items/\(id).json"

    if let response = apiClient.fullRequest(path: path, to: BookmarkResponse.self, method: .post) {
      let statusCode = response.response.statusCode
      let data = response.value

      if statusCode == 201 {
        return data.status == "Created"
      }
    }

    return false
  }

  public func removeBookmark(id: Int) -> Bool {
    let path = "video/bookmarks/items/\(id).json"

    if let response = apiClient.fullRequest(path: path, to: BookmarkResponse.self, method: .delete) {
      let statusCode = response.response.statusCode

      if statusCode == 204 {
        return true
      }
    }

    return false
  }

  public func getTopicItems(_ id: String="best", perPage: Int=PER_PAGE, page: Int=1) -> PaginatedMediaData? {
    let path = "video/media/\(id).json"

    var params: [URLQueryItem] = []
    params.append(URLQueryItem(name: "per_page", value: String(perPage)))
    params.append(URLQueryItem(name: "page", value: String(page)))

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .paginatedMedia(let value) = response.value.data {
        return value
      }
    }

    return nil
  }

  public func getLiveChannels(favoriteOnly: Bool=false, offset: String? = nil) -> [LiveChannel] {
    let format = "mp4"

    let path = "video/live/channels.json"

    var params: [URLQueryItem] = []
    params.append(URLQueryItem(name: "format", value: format))
    params.append(URLQueryItem(name: "allowed_only", value: String(1)))
    params.append(URLQueryItem(name: "favorite_only", value: String(favoriteOnly)))

    if let offset = offset {
      params.append(URLQueryItem(name: "offset", value: offset))
    }

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .liveChannels(let liveChannels) = response.value.data {
        return liveChannels
      }
    }

    return []
  }

  public func getLiveChannelsByCategory(favoriteOnly: Bool=false, offset: String? = nil, category: Int=0) -> [LiveChannel] {
    let format = "mp4"

    let path = "video/live/category/\(category).json"

    var params: [URLQueryItem] = []
    params.append(URLQueryItem(name: "format", value: format))
    params.append(URLQueryItem(name: "allowed_only", value: String(1)))
    params.append(URLQueryItem(name: "favorite_only", value: String(favoriteOnly)))

    if let offset = offset {
      params.append(URLQueryItem(name: "offset", value: offset))
    }

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self, params: params) {
      if case .liveChannels(let liveChannels) = response.value.data {
        return liveChannels
      }
    }

    return []
  }

  public func addFavoriteChannel(id: Int) -> Bool {
    let path = "video/live/\(id)/favorite.json"

    let _ = apiClient.fullRequest(path: path, to: Bool.self, method: .post)

    return true
  }

  public func removeFavoriteChannel(id: Int) -> Bool {
    let path = "video/live/\(id)/favorite.json"

    let _ = apiClient.fullRequest(path: path, to: Bool.self, method: .delete)

    return true
  }

  public func getLiveSchedule(liveChannelId: String, date: Date = Date()) -> (value: String, response: ApiResponse)? {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd@nbsp;HH:mm"
//
//    let dateString = dateFormatter.string(from: date)
//
//    let params = ["date": dateString]

    let path = "video/live/schedule/\(liveChannelId).json"

    return apiClient.fullRequest(path: path, to: String.self)
  }

  public func getLiveCategories() -> [Name] {
    let path = "video/live/category.json"

    if let response = apiClient.fullRequest(path: path, to: MediaResponse.self) {
      if case .names(let categories) = response.value.data {
        // regroup categories

        var regrouped = [Name]()

        regrouped.append(categories[0])
        regrouped.append(categories[1])
        regrouped.append(categories[4])
        regrouped.append(categories[6])
        regrouped.append(categories[8])
        regrouped.append(categories[3])
        regrouped.append(categories[7])
        regrouped.append(categories[5])
        regrouped.append(categories[2])

        return regrouped
      }
    }

    return []
  }
}