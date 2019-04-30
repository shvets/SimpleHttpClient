import Foundation

//extension URLSession {
//  func dataTask(with url: URL, completionHandler: @escaping Handler<Data>) {
//    dataTask(with: url) { data, _, error in
//      if let error = error {
//        completionHandler(.failure(error))
//      } else {
//        completionHandler(.success(data ?? Data()))
//      }
//    }
//  }
//
//  func dataTask(with url: URL, _ completionHandler: @escaping APIClientCompletion) {
//    dataTask(with: url) { data, response, error in
//      guard let httpResponse = response as? HTTPURLResponse else {
//        completionHandler(.failure(.requestFailed)); return
//      }
//
//      completionHandler(.success(APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data)))
//    }
//  }
//}