import Foundation

public enum APIClientError: Error, Equatable {
    case cantEncodeParams
    case invalidAPIURL
    
    case invalidResponse
    case responseError(ResponseError)
}
