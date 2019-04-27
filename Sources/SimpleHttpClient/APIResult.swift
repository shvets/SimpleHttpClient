enum APIResult<Body> {
  case success(APIResponse<Body>)
  case failure(APIError)
}
