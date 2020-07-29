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
    var serverPath: ServerPaths { get }

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
        return mainURL.appendingPathComponent(serverPath.path)
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


public enum ServerPaths {
    
    case login
    case logout
    
    case dashboardList
    case visStateContent
    
    case indexPatternList
    case videoData

    var path: String {
        switch self {
        case .login: return "api/v1/auth/login"
        case .logout: return "api/v1/auth/logout"
        case .dashboardList: return "api/saved_objects/_find"
        case .visStateContent: return "api/saved_objects/_bulk_get"
        case .indexPatternList: return "api/saved_objects/_find"
        case .videoData: return "api/console/proxy"
        }
    }
}
