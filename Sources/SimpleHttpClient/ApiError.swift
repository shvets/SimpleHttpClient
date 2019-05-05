enum ApiError: Error {
  case genericError(error: Error)

  case invalidURL

  case notHttpResponse

  case bodyEncodingFailed

  case bodyDecodingFailed

  case emptyResponse
}
