//
//  SavedSearchDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 17/08/2020.
//

import Foundation

public class SavedSearchDataParams: VizDataParamsBase {
    
    public var savedSearchId: String?
    public var pageSize: Int   =   10
    public var pageNum: Int    =   0
        
    //MARK: Functions
    override func generatedQueryDataForVisualization(_ indexPatternName: String, params: VizDataParamsBase?) -> Data? {
        return nil
    }
    
    func generatedQueryDataForSavedSearch(_ indexPatternName: String, sort: [String], params: SavedSearchDataParams?) -> Data? {
        
        let indexJson: [String: Any] = ["index": indexPatternName,
                                        "ignore_unavailable": true]
        
        
        var mustFilters: [[String: Any]] = []
        if let indexPattern = ServiceProvider.shared.indexPatternsList.filter({ $0.id == params?.indexPatternId }).first,
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

    func postResponseProcedure(_ response: Any, visStateHolder: VisStateHolderBase?) -> [[String: Any]] {
        
        guard let result = response as? [String: Any], var resp = (result["responses"] as? [[String: Any]])?.first,
        var hitsDict = resp["hits"] as? [String: Any] else {
            return []
        }
        
        var timeColumnValue = "Time" //default name. To be used if the property name is @timestamp
        if let timeSortValue = visStateHolder?.sortList.first {
            if timeSortValue == "@timestamp" {
                
                let innerHitsList = hitsDict["hits"] as? [[String: Any]] ?? []
                
                let updatedHits =  innerHitsList.compactMap { (dict) -> [String: Any]? in
                    var updatedDict = dict
                    var sourceDict = dict["_source"] as? [String: Any]
                    let timeSortContent = sourceDict?[timeSortValue]
                    sourceDict?[timeColumnValue] = timeSortContent

                    updatedDict["_source"] = sourceDict
                    return updatedDict
                }
                
                hitsDict["hits"] = updatedHits
                
            } else {
                timeColumnValue = timeSortValue
            }
        }
        
        if var columns = visStateHolder?.columns {
            
            if !columns.contains(timeColumnValue) {
                columns.insert(timeColumnValue, at: 0)
            }
            hitsDict["columns"] = columns
        }
                
        resp["hits"] = hitsDict
        return [resp]
    }
}
