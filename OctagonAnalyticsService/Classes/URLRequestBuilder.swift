//
//  URLRequestBuilder.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 19/07/2020.
//

import Foundation
import Alamofire

public protocol URLRequestBuilder: URLRequestConvertible {

    var mainURL: URL { get }
    var requestURL: URL { get }
    // MARK: - Path
    var path: ServerPaths { get }

    var headers: HTTPHeaders { get }
    // MARK: - Parameters
    var parameters: Parameters? { get }

    // MARK: - Methods
    var method: HTTPMethod { get }

    var encoding: ParameterEncoding { get }

    var urlRequest: URLRequest { get }
    
}

public extension URLRequestBuilder {
    var mainURL: URL {
        return URL(string: ServiceConfiguration.baseUrl)!
    }

    var requestURL: URL {
        return mainURL.appendingPathComponent(path.rawValue)
    }

    var headers: HTTPHeaders {
        var header = HTTPHeaders()
        header["kbn-xsrf"] = "reporting"
        return header
    }

    var defaultParams: Parameters {
        return Parameters()
    }

    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }

    var urlRequest: URLRequest {
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.name) }
        return request
    }

    func asURLRequest() throws -> URLRequest {
        return try encoding.encode(urlRequest, with: parameters)
    }

}


public enum ServerPaths: String {
    case login  =   "api/v1/auth/login"
    case logout =   "api/v1/auth/logout"
}
