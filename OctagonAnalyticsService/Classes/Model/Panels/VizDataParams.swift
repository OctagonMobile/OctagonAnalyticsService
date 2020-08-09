//
//  VizDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 06/08/2020.
//

import Foundation

public class VizDataParams {
    public var indexPatternId: String
    public var timeFieldName: String?
    public var panelType: PanelType    =   .unKnown
    public var timeFrom: String?
    public var timeTo: String?
    public var filters: [[String: Any]] =   []
    
    //MARK: Functions
    public init(_ indexPatternId: String) {
        self.indexPatternId     =   indexPatternId
    }
    
    func prepareVisualizationFilter(_ filterObj: [String: Any]) -> [String: Any]? {

        let filterType = filterObj["filterType"] as? String ?? ""

        switch filterType {
        case "terms":
            guard let filterField = filterObj["filterField"] as? String else { return nil }
            let filterWord = (filterObj["filterValue"] as? String) == nil ? "terms" : "match_phrase"
            if let filterValue = filterObj["filterValue"] as? String {
                return [ "\(filterWord)" : [filterField : filterValue]]
            } else if let filterValue = filterObj["filterValue"] as? [String: Any] {
                return [ "\(filterWord)" : [filterField : filterValue]]
            }
            return nil
            
        case "range":
            
            if let filterField = filterObj["filterField"] as? String,
                let from = filterObj["filterRangeFrom"] as? String,
                let to = filterObj["filterRangeTo"] as? String {
                return [ "\(filterField)" : ["gte" : from, "lt": to]]
            }

        case "date_histogram":
            if let filterField = filterObj["filterField"] as? String,
                let filterValue = filterObj["filterRangeFrom"] as? String,
                let filterValInt = Int(filterValue) {
                
                return [ "\(filterField)" : ["gte" : filterValInt, "lt": filterValInt + 20000]]
            }

        case "geohash_grid":
            if let filterField = filterObj["filterField"] as? String,
                let filterValue = filterObj["filterValue"] as? [String: Any] {
                
                return ["geo_bounding_box": [ "\(filterField)" : filterValue]]
            }
            
        default:
            return nil
        }
        return nil
    }
    
    func checkForScriptedFields() -> [IPFieldService] {
        guard let indexPattern = ServiceProvider.shared.indexPatternsList.filter({ $0.id == indexPatternId }).first else {
            return []
        }
        return indexPattern.fields.filter({ $0.scripted })
    }
    
    func prepareScriptedFieldsObj(_ scriptedFields: [IPFieldService]) -> [String: Any] {
        
        var dict: [String: Any] =   [:]
        scriptedFields.forEach { (field) in
            guard let script = field.script, let lang = field.lang else { return }
            dict[field.name] = ["script": ["inline": script, "lang": lang]]
        }

        return dict
    }
}