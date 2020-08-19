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
        case .loadVisualizationData(indexPatternName: let ipName, vizDataParams: _):
            return ["index": ipName]
        case .loadSavedSearchData(indexPatternName: let ipName, sort: _, searchDataParams: _):
            return ["index": ipName]
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
            return generatedQueryDataForVisualization(ipName, params: params)
        case .loadSavedSearchData(indexPatternName: let ipName, sort: let sortList, searchDataParams: let params):
            return generatedQueryDataForSavedSearch(ipName, sort: sortList, params: params)
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

extension DashboardServiceBuilder {
    func generatedQueryDataForVisualization(_ indexPatternName: String, params: VizDataParams?) -> Data? {
        
        let indexJson: [String: Any] = ["index": indexPatternName,
                                        "ignore_unavailable": true]
        
        
        var mustFilters: [[String: Any]] = []
        if let indexPattern = ServiceProvider.shared.indexPatternsList.filter({ $0.id == params?.indexPatternId}).first,
            !indexPattern.timeFieldName.isEmpty {
            if let rangeFilter = getRangeFilter(params, timeStampProp: indexPattern.timeFieldName) {
                mustFilters.append(rangeFilter)
            }
        }

        
        var mustNotFilters: [[String: Any]] = []
        
        params?.filters.forEach({ (dict) in
            if let filter = params?.prepareVisualizationFilter(dict) {
                let isInverted = filter["isFilterInverted"] as? Bool ?? false
                
                isInverted ? mustNotFilters.append(dict) : mustFilters.append(dict)
            }
        })
        
        if let searchQueryPanelObj = params?.prepareSearchContent(params?.searchQueryPanel) {
            mustFilters.append(searchQueryPanelObj)
        }
        
        if let searchQueryDashboardObj = params?.prepareSearchContent(params?.searchQueryDashboard) {
            mustFilters.append(searchQueryDashboardObj)
        }
        
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
             "aggs": params?.generatedAggregationJson() ?? [:],
             "script_fields": scriptedFieldObj
        ]
        
        let indexJsonString = indexJson.jsonStringRepresentation ?? ""
        let queryJSONString = queryJSON.jsonStringRepresentation ?? ""

        let finalContent = indexJsonString + "\n" + queryJSONString + "\n"
        return finalContent.data(using: .utf8)!

    }
    
    func generatedQueryDataForSavedSearch(_ indexPatternName: String, sort: [String], params: SavedSearchDataParams?) -> Data? {
        
        let indexJson: [String: Any] = ["index": indexPatternName,
                                        "ignore_unavailable": true]
        
        
        var mustFilters: [[String: Any]] = []
        if let indexPattern = ServiceProvider.shared.indexPatternsList.filter({ $0.id == params?.indexPatternId}).first,
            !indexPattern.timeFieldName.isEmpty {
            if let rangeFilter = getRangeFilter(params, timeStampProp: indexPattern.timeFieldName) {
                mustFilters.append(rangeFilter)
            }
        }

        
        var mustNotFilters: [[String: Any]] = []
        
        params?.filters.forEach({ (dict) in
            if let filter = params?.prepareVisualizationFilter(dict) {
                let isInverted = filter["isFilterInverted"] as? Bool ?? false
                
                isInverted ? mustNotFilters.append(dict) : mustFilters.append(dict)
            }
        })
        
//        let scriptedFieldsArray = params?.checkForScriptedFields() ?? []
//        let scriptedFieldObj = params?.prepareScriptedFieldsObj(scriptedFieldsArray) ?? [:]
        
        let pageSize = params?.pageSize ?? 10
        let fromPageNumber = (params?.pageNum ?? 0) * pageSize
        
        
        var sortDict: [String: Any] = [:]
        if sort.count > 1 {
            sortDict["\(sort[0])"] = ["order": "\(sort[1])"]
        }
        
        let queryJSON: [String: Any]  =
            ["query":
                ["bool":
                    [
                        "must": mustFilters,
                        "must_not": mustNotFilters,
                        "filter": []
                    ]
                ],
             "from": fromPageNumber,
             "size": pageSize,
             "sort": sortDict
        ]
        
        let indexJsonString = indexJson.jsonStringRepresentation ?? ""
        let queryJSONString = queryJSON.jsonStringRepresentation ?? ""

        let finalContent = indexJsonString + "\n" + queryJSONString + "\n"
        return finalContent.data(using: .utf8)!

    }

    
    func getRangeFilter(_ visStateContent: VizDataParams?, timeStampProp: String?) -> [String: Any]? {
        var fromDateValue: Int64    =   0
        if let fromDateStr = visStateContent?.timeFrom {
            if let fromDate = fromDateStr.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
                fromDateValue = fromDate.millisecondsSince1970
            } else if let fromDate = DateParser.shared.parse(fromDateStr) {
                fromDateValue = fromDate.millisecondsSince1970
            }
        }
        
        var toDateValue: Int64    =   0
        if let toDateStr  = visStateContent?.timeTo  {
            if let toDate = toDateStr.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ") {
                toDateValue = toDate.millisecondsSince1970
            } else if let toDate = DateParser.shared.parse(toDateStr) {
                toDateValue = toDate.millisecondsSince1970
            }
        }

        if let timeFieldName = timeStampProp, !timeFieldName.isEmpty,
            fromDateValue != 0, toDateValue != 0 {
            let timeRangeFilter = [timeFieldName : ["gte": fromDateValue, "lte": toDateValue, "format": "epoch_millis"]]
            return ["range": timeRangeFilter]
        }
        return nil
    }
}
