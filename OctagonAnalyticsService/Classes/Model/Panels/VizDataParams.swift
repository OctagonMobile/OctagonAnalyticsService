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
    public var aggregationsArray: [AggregationService]         = []

    private var otherAggregationList: [AggregationService] {
        return aggregationsArray.filter({ $0.schema != "segment" })
    }

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
        
    func createAggsDictForAggregationAtIndex(_ index: Int = 0) -> [String: Any] {
        
        let aggregation = otherAggregationList[index]
        var idAggs: [String: Any] = [:]
        switch aggregation.bucketType {
        case .terms:
            let size = aggregation.params?.size ?? 0
            var internalDict: [String: Any] =
                ["field": "\(aggregation.field)",
                "size": size]
            
            if let order = aggregation.params?.order {
                internalDict["order"] = ["_count":"\(order)"]
            }

            idAggs = ["\(aggregation.id)": ["terms": internalDict]]
            break
        default:
            break
        }
        
        let aggIndex = index + 1
        
        if otherAggregationList.count != 1,
            aggIndex <= otherAggregationList.count - 1 {
            let previousAggregation = otherAggregationList[index]
            if var dict = idAggs[previousAggregation.id] as? [String: Any] {
                dict["aggs"] = createAggsDictForAggregationAtIndex(aggIndex)
                idAggs[previousAggregation.id] = dict
            }
        }
        return idAggs
    }
}
