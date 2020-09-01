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
    
    case loadVisualizationData(indexPatternName: String, vizDataParams: VizDataParamsBase?)

    case loadSavedSearchData(indexPatternName: String, sort: [String], searchDataParams:SavedSearchDataParams?)

    var serverPath: ServerPaths {
        switch self {
        case .loadDashboards:
            return ServerPaths.dashboardList
        case .loadVisStateData:
            return ServerPaths.visStateContent
        case .loadVisualizationData, .loadSavedSearchData:
            return ServerPaths.visualizationData
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .loadDashboards(pageNumber: let pageNo, pageSize: let pageSize):
            return ["type": "dashboard", "page": pageNo, "per_page": pageSize]
        default:
            return nil
        }
    }
    
    var queryParameters: [String : String]? {
        switch self {
        case .loadVisualizationData, .loadSavedSearchData:
            return ServiceConfiguration.version.vizDataQueryParams
        default:
            return nil
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .loadVisStateData, .loadVisualizationData, .loadSavedSearchData:
            return HTTPMethod.post
        default:
            return HTTPMethod.get
        }
    }
    
    var headers: HTTPHeaders {
        var header = HTTPHeaders()
        header["kbn-xsrf"] = "reporting"

        switch self {
        case .loadVisStateData, .loadVisualizationData, .loadSavedSearchData:
            header["Content-Type"]  =   "application/json"
        default:
            break
        }
        return header
    }
    
    var httpBodyContent: Data? {
        switch self {
        case .loadVisStateData(panelInfo: let panelInfoList):
            var computedParams: [[String: Any?]] = []
            for info in panelInfoList {
                computedParams.append(["type" : info.type, "id" : info.id])
            }
            return try? JSONSerialization.data(withJSONObject: computedParams, options: .prettyPrinted)
            
        case .loadVisualizationData(indexPatternName: let ipName, vizDataParams: let params):
            return params?.generatedQueryDataForVisualization(ipName, params: params)
        case .loadSavedSearchData(indexPatternName: let ipName, sort: let sortList, searchDataParams: let params):
            return params?.generatedQueryDataForSavedSearch(ipName, sort: sortList, params: params)
        default:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding {
        switch self {
        case .loadVisStateData:
            return JSONEncoding.default
        case .loadVisualizationData, .loadSavedSearchData:
            return URLEncoding.queryString
        default:
            return URLEncoding.default
        }
    }
}
