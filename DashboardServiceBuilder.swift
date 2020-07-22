//
//  DashboardServiceBuilder.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 20/07/2020.
//

import Foundation
import Alamofire

public enum DashboardServiceBuilder: URLRequestBuilder {
    
    case loadDashboards(pageNumber: Int, pageSize: Int)
    case logout
    
    public var path: ServerPaths {
        switch self {
        case .loadDashboards:
            return ServerPaths.dashboardList
        case .logout:
            return ServerPaths.logout
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .loadDashboards(pageNumber: let pageNo, pageSize: let pageSize):
            return ["type": "dashboard", "page": pageNo, "per_page": pageSize]
        case .logout:
            return nil
        }
    }
    
    public var method: HTTPMethod {
        return HTTPMethod.get
    }
    
    public var encoding: ParameterEncoding {
        return URLEncoding.default
    }
}
