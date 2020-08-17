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
    func postResponseProcedure(_ response: Any, columns: [String]) -> [[String: Any]] {
        
        guard let result = response as? [String: Any], var resp = (result["responses"] as? [[String: Any]])?.first,
        var hitsDict = resp["hits"] as? [String: Any] else {
            return []
        }
        
        hitsDict["columns"] = columns
        resp["hits"] = hitsDict
        return [resp]
    }
}
