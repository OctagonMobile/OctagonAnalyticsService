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
    case loadVisStateForId(panelId: String)
    
    public var serverPath: ServerPaths {
        switch self {
        case .loadDashboards:
            return ServerPaths.dashboardList
        case .loadVisStateForId(panelId: let id):
            return ServerPaths.visStateData(panelId: id)
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .loadDashboards(pageNumber: let pageNo, pageSize: let pageSize):
            return ["type": "dashboard", "page": pageNo, "per_page": pageSize]
        case .loadVisStateForId:
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
