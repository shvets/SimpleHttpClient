enum ApiError: Error {
  case invalidURL

  case notHttpResponse

  case bodyEncodingFailed

  case bodyDecodingFailed
}
