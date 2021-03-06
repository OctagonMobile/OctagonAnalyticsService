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

    var queryParameters: [String: String]? { get }
    // MARK: - Methods
    var method: HTTPMethod { get }

    var encoding: ParameterEncoding { get }

    var urlRequest: URLRequest { get }
    
    var httpBodyContent: Data? { get }
}

public extension URLRequestBuilder {
    var mainURL: URL {
        return URL(string: ServiceConfiguration.baseUrl)!
    }

    var requestURL: URL {
        let url = mainURL.appendingPathComponent(serverPath.path)
        if let queryParams = queryParameters {
            return url.URLByAppendingQueryParameters(queryParams) ?? url
        }
        return url
    }

    var headers: HTTPHeaders {
        return defHeaders
    }
    
    var defHeaders: HTTPHeaders {
        var header = HTTPHeaders()
        header["kbn-xsrf"] = "reporting"
        if ServiceConfiguration.isKeycloackEnabled,
            let accessToken = ServiceConfiguration.keycloakAccessToken {
            header["Authorization"] = "Bearer \(accessToken)"
        }
        return header
    }

    var defaultParams: Parameters {
        return Parameters()
    }

    var queryParameters: [String: String]? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    var httpBodyContent: Data? {
        return nil
    }
    
    var urlRequest: URLRequest {
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.name) }
        request.httpBody = httpBodyContent
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
    
    case visualizationData

    case indexPatternList
    case videoData

    case canvasList

    var path: String {
        switch self {
        case .login: return "api/v1/auth/login"
        case .logout: return "api/v1/auth/logout"
        case .dashboardList: return "api/saved_objects/_find"
        case .visStateContent: return "api/saved_objects/_bulk_get"
        case .visualizationData: return "elasticsearch/_msearch"
        case .indexPatternList: return "api/saved_objects/_find"
        case .videoData: return "api/console/proxy"
        case .canvasList: return "api/saved_objects/_find"
        }
    }
}
