enum ApiError: Error {
  case invalidURL

  case bodyEncodeFailed

  case requestFailed

  case decodingFailure
}
