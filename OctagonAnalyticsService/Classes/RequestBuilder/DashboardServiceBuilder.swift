//
//  DashboardServiceBuilder.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 20/07/2020.
//

import Foundation
import Alamofire

enum DashboardServiceBuilder: URLRequestBuilder {
    
    case loadDashboards(pageNumber: Int, pageSize: Int)
    case loadVisStateData(panelInfo: [PanelInfo])

    var serverPath: ServerPaths {
        switch self {
        case .loadDashboards:
            return ServerPaths.dashboardList
        case .loadVisStateData:
            return ServerPaths.visStateContent
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .loadDashboards(pageNumber: let pageNo, pageSize: let pageSize):
            return ["type": "dashboard", "page": pageNo, "per_page": pageSize]
        case .loadVisStateData:
            return nil
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .loadVisStateData:
            return HTTPMethod.post
        default:
            return HTTPMethod.get
        }
    }
    
    var headers: HTTPHeaders {
        var header = HTTPHeaders()
        header["kbn-xsrf"] = "reporting"

        switch self {
        case .loadVisStateData:
            header["Content-Type"]  =   "application/json"
        default:
            break
        }
        return header
    }
    
    public var urlRequest: URLRequest {
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.name) }
        
        switch self {
        case .loadVisStateData(panelInfo: let panelInfoList):
            var computedParams: [[String: Any?]] = []
            for info in panelInfoList {
                computedParams.append(["type" : info.type, "id" : info.id])
            }
            request.httpBody = try? JSONSerialization.data(withJSONObject: computedParams, options: .prettyPrinted)
        default: break
        }
        return request
    }
    
    public var encoding: ParameterEncoding {
        switch self {
        case .loadVisStateData:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }
}