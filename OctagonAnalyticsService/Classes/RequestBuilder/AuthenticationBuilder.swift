//
//  AuthenticationBuilder.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 19/07/2020.
//

import Foundation
import Alamofire

public enum AuthenticationBuilder: URLRequestBuilder {
    
    case login(userId: String, password: String)
    case logout
    
    public var serverPath: ServerPaths {
        switch self {
        case .login:
            return ServerPaths.login
        case .logout:
            return ServerPaths.logout
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .login(userId: let userId, password: let password):
            return ["username": userId, "password": password]
        case .logout:
            return nil
        }
    }
    
    public var method: HTTPMethod {
        return HTTPMethod.post
    }
    
    public var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}
