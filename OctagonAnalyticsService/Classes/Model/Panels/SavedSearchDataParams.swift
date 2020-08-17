//
//  SavedSearchDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 17/08/2020.
//

import Foundation

public class SavedSearchDataParams: VizDataParams {
    
    public var savedSearchId: String?
    public var pageSize: Int   =   10
    public var pageNum: Int    =   0
        
    //MARK: Functions
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
