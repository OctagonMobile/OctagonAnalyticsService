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
    
    case loadVisualizationData(indexPatternName: String, vizDataParams:VizDataParams?)

    var serverPath: ServerPaths {
        switch self {
        case .loadDashboards:
            return ServerPaths.dashboardList
        case .loadVisStateData:
            return ServerPaths.visStateContent
        case .loadVisualizationData:
            return ServerPaths.visualizationData
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .loadDashboards(pageNumber: let pageNo, pageSize: let pageSize):
            return ["type": "dashboard", "page": pageNo, "per_page": pageSize]
        case .loadVisualizationData(indexPatternName: let ipName, vizDataParams: _):
            return ["index": ipName]
        default:
            return nil
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .loadVisStateData, .loadVisualizationData:
            return HTTPMethod.post
        default:
            return HTTPMethod.get
        }
    }
    
    var headers: HTTPHeaders {
        var header = HTTPHeaders()
        header["kbn-xsrf"] = "reporting"

        switch self {
        case .loadVisStateData, .loadVisualizationData:
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
            return generatedQueryDataForVisualization(ipName, params: params)
        default:
            return nil
        }
    }
    
    public var encoding: ParameterEncoding {
        switch self {
        case .loadVisStateData:
            return JSONEncoding.default
        case .loadVisualizationData:
            return URLEncoding.queryString
        default:
            return URLEncoding.default
        }
    }
}

extension DashboardServiceBuilder {
    func generatedQueryDataForVisualization(_ indexPatternName: String, params: VizDataParams?) -> Data? {
        
        let indexJson: [String: Any] = ["index": indexPatternName,
                                        "ignore_unavailable": true]
        
        
        var mustFilters: [[String: Any]] = []
        if let rangeFilter = getRangeFilter(params) {
            mustFilters.append(rangeFilter)
        }
        
        var mustNotFilters: [[String: Any]] = []
        
        params?.filters.forEach({ (dict) in
            if let filter = params?.prepareVisualizationFilter(dict) {
                let isInverted = filter["isFilterInverted"] as? Bool ?? false
                
                isInverted ? mustNotFilters.append(dict) : mustFilters.append(dict)
            }
        })
        
        let scriptedFieldsArray = params?.checkForScriptedFields() ?? []
        let scriptedFieldObj = params?.prepareScriptedFieldsObj(scriptedFieldsArray) ?? [:]
        
        let queryJSON: [String: Any]  =
            ["query":
                ["bool":
                    [
                        "must": mustFilters,
                        "must_not": mustNotFilters,
                        "filter": []
                    ]
                ],
             "size": 100,
             "_source": [
               "excludes": []
             ],
             "aggs": params?.createAggsDictForAggregationAtIndex() ?? [:],
             "script_fields": scriptedFieldObj
        ]
        
        let indexJsonString = indexJson.jsonStringRepresentation ?? ""
        let queryJSONString = queryJSON.jsonStringRepresentation ?? ""

        let finalContent = indexJsonString + "\n" + queryJSONString + "\n"
        return finalContent.data(using: .utf8)!

    }
    
    func getRangeFilter(_ visStateContent: VizDataParams?) -> [String: Any]? {
        var fromDateValue: Int64    =   0
        if let fromDateStr = visStateContent?.timeFrom,
            let fromDate = fromDateStr.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
            fromDateValue = fromDate.millisecondsSince1970
        }
        
        var toDateValue: Int64    =   0
        if let toDateStr  = visStateContent?.timeTo,
            let toDate = toDateStr.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
            toDateValue = toDate.millisecondsSince1970
        }

        if let timeFieldName = visStateContent?.timeFieldName, !timeFieldName.isEmpty {
            let timeRangeFilter = [timeFieldName : ["gte": fromDateValue, "lte": toDateValue, "format": "epoch_millis"]]
            return ["range": timeRangeFilter]
        }
        return nil
    }
}
