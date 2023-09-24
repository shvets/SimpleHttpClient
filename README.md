# SimpleHttpClient

Simple Swift HTTP client package.

## How to use library
    
### Basic usage
        
Create client:
    
```swift
import SimpleHttpClient

let url = URL(string: "https://jsonplaceholder.typicode.com")

var client = ApiClient(url!)
```

Create request:
    
```swift
let request = ApiRequest(path: "posts")
```

Get data asynchronously:

```swift
client.fetch(request) { (result) in
  switch result {
    case .success(let response):
      processData(client, response.data)

    case .failure(let error):
      print("Error: \(error)")
  }
}
```

or synchronously:

```swift
let response = try Await.await() { handler in
  client.fetch(request, handler)
}

if let response = response, let data = response.data {
  processData(client, response.data)
}
else {
  print("Error: \(error)")
}
```    

Here we are using await function that is converting asynchronous action into synchronous
based on semaphores.

### Creating different types of request

During request creation you can specify path, queryItems, method, headers or body. For example:

```swift
// 1.
let postRequest = ApiRequest(path: "posts", method: .post)

// 2.
var queryItems: Set<URLQueryItem> = []
queryItems.insert(URLQueryItem(name: "color", value: "red"))

let requestWithQuery = ApiRequest(path: "posts", queryItems: queryItems)

// 3.
let body = content.data(using: .utf8, allowLossyConversion: false)
let postWithBodyRequest = ApiRequest(path: "posts", method: .post, body: body)
```

### Converting raw data into objects

Api client has generic code for helping to decode data into appropriate structure. For example,
if you know that response is a list of posts:

```swift
struct Post: Codable {
  let userId: Int
  let id: Int
  let title: String
  let body: String
}
```

your processData() method may look like this:

```swift
func processData(client: ApiClient, data: Data?) {
  if let data = data {
    do {
      let posts = try client.decode(data, to: [Post].self)
        
      if let posts = posts {
        println(posts.prettify())
      }
    }
    catch {
      println("Error during decoding: \(error)")
    }
  }
}
```

### Working with html response

If you need to parse http response you can use SwiftSoup library (https://github.com/scinfu/SwiftSoup).

```swift
import Foundation
import SwiftSoup

extension Data {
  public func toDocument(encoding: String.Encoding = .utf8) throws -> Document? {
    var document: Document?

    if let html = String(data: self, encoding: encoding) {
      document = try SwiftSoup.parse(html)
    }

    return document
  }
}

func processData(client: ApiClient, data: Data?) {
  if let data = data {
    do {
      let document = try data.toDocument(encoding: .utf8)
        
      if let document = document {
        let articles = try document.select("div[class=article]")

        for article in articles.array() {
          let name = try article.attr("name")
          let link = try article.attr("link")
  
          print("Article: \(article), link: \(link)")
        }
      }
    }
    catch {
      println("Error during decoding: \(error)")
    }
  }
}
```

    # Commands
    
```sh
swift package generate-xcodeproj
swift package init --type=executable
swift package init --type=library
swift package resolve
swift build
swift test -l
swift test -s <testname>
swift package show-dependencies
swift package show-dependencies --format json
swift -I .build/debug -L .build/debug -lSimpleHttpClient
./.build/debug/grabbook https://audioknigi.club/zeland-vadim-zhrica-itfat
./.build/debug/grabbook --boo http://audioboo.ru/umor/17092-heller-dzhozef-popravka-22.html
./.build/debug/grabbook --zvook http://bookzvuk.ru/zhizn-i-neobyichaynyie-priklyucheniya-soldata-ivana-chonkina-1-litso-neprikosnovennoe-vladimir-voynovich-audiokniga-onlayn/
```

# Publishing

```bash
git tag 1.0.9
git push --tags
```

# Links
    
- https://tim.engineering/break-up-third-party-networking-urlsession
- https://mecid.github.io/2019/04/17/asynchronous-completion-handlers-with-result-type
- https://medium.com/better-programming/better-swift-codable-models-through-composition-a6b109b7e8c7
- https://www.swiftbysundell.com/posts/type-safe-identifiers-in-swift
- https://mecid.github.io/2019/05/22/storing-codable-structs-on-the-disk/
  