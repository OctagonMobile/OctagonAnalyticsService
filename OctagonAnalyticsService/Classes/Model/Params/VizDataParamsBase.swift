//
//  VizDataParamsBase.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 24/08/2020.
//

import Foundation

public class VizDataParamsBase {
    public var panelType: PanelType    =   .unKnown
    public var timeFrom: String?
    public var timeTo: String?
    public var searchQueryPanel: String  =   ""
    public var searchQueryDashboard: String  =   ""

    public var filters: [[String: Any]] =   []
    public var aggregationsArray: [AggregationService]         = []

    public var indexPatternIdList: [String] =   []
    
    public init(_ indexPatternIds: [String]) {
        self.indexPatternIdList     =   indexPatternIds
    }
    
    func generatedQueryDataForVisualization(_ indexPatternName: String, params: VizDataParamsBase?) -> Data? {
        return nil
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
    
    func prepareSearchContent(_ searchTerm: String?) -> [String: Any]? {
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            return ["query_string": ["analyze_wildcard": true, "query": searchTerm]]
        }
        return nil
    }

    func checkForScriptedFields() -> [IPFieldService] {
        guard let indexPattern = ServiceProvider.shared.indexPatternsList.filter({ $0.id == indexPatternIdList.first }).first else {
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

    func generatedAggregationJson() -> [String: Any] {
        return [:]
    }
        
    func getRangeFilter(_ visStateContent: VizDataParamsBase?, timeStampProp: String?) -> [String: Any]? {
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
    
    func postResponseProcedure(_ response: Any) -> Any? {
        return [:]
    }
}
