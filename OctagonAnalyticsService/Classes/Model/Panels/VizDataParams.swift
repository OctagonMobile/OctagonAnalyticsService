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
    public var searchQueryPanel: String  =   ""
    public var searchQueryDashboard: String  =   ""

    /// Interval is used only for Date Histogram
    public var interval: String?
    public var filters: [[String: Any]] =   []
    public var aggregationsArray: [AggregationService]         = []

    private var otherAggregationList: [AggregationService] {
        return aggregationsArray.filter({ $0.schema != "metric" })
    }

    private var metricAggregation: AggregationService? {
        return aggregationsArray.filter({ $0.schema == "metric"}).first
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
    
    func prepareSearchContent(_ searchTerm: String?) -> [String: Any]? {
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            return ["query_string": ["analyze_wildcard": true, "query": searchTerm]]
        }
        return nil
    }
     
    func generatedAggregationJson() -> [String: Any] {
        
        if panelType == .gauge || panelType == .goal {
            guard let metricAggregation = metricAggregation else { return [:] }
            return createMetricAggregationFor(metricAggregation)
        }
        return createAggsDictForAggregationAtIndex()
    }

    func createAggsDictForAggregationAtIndex(_ index: Int = 0) -> [String: Any] {
        
        guard index < otherAggregationList.count else { return [:] }
        let aggregation = otherAggregationList[index]
        var idAggs: [String: Any] = [:]
        switch aggregation.bucketType {
        case .terms:
            let size = aggregation.params?.size ?? 0
            var internalDict: [String: Any] =
                ["field": "\(aggregation.field)",
                "size": size]
            
            if let order = aggregation.params?.order {
                if metricAggregation?.metricType == .count {
                    internalDict["order"] = ["_count":"\(order)"]
                } else {
                    if let orderBy = aggregation.params?.orderBy {
                        internalDict["order"] = ["\(orderBy)":"\(order)"]
                    }
                }
            }

            var dict = ["terms": internalDict]
            if let metricAggs = addMetricAggsIfRequired(index) {
                dict["aggs"] = metricAggs
            }

            idAggs = ["\(aggregation.id)": dict]
            break
            
        case .range:
            
            var internalDict: [String: Any] =
                ["field": "\(aggregation.field)",
                    "keyed": true]

            var ranges: [[String: Any]] = []
            for range in aggregation.params?.ranges ?? [] {
                ranges.append(["from": range.from, "to": range.to])
            }
            internalDict["ranges"] = ranges
            
            var dict = ["range": internalDict]
            
            if let metricAggs = addMetricAggsIfRequired(index) {
                dict["aggs"] = metricAggs
            }
            idAggs = ["\(aggregation.id)": dict]
            break
            
        case .histogram:
            
            var internalDict: [String: Any] = ["field": "\(aggregation.field)"]
            
            if let intervl = aggregation.params?.intervalInt {
                internalDict["interval"] = intervl
            }
            var dict = ["\(aggregation.bucketType.rawValue)": internalDict]
            
            if let metricAggs = addMetricAggsIfRequired(index) {
                dict["aggs"] = metricAggs
            }
            
            idAggs = ["\(aggregation.id)": dict]
            
            break

        case .dateHistogram:
            
            var internalDict: [String: Any] = ["field": "\(aggregation.field)"]
            if let intervl = interval {
                internalDict["interval"] = intervl
            }
            var dict = ["\(aggregation.bucketType.rawValue)": internalDict]
            
            if let metricAggs = addMetricAggsIfRequired(index) {
                dict["aggs"] = metricAggs
            }

            idAggs = ["\(aggregation.id)": dict]
            break
        case .geohashGrid:
            var idDict = [String: Any]()
            let geoHashGridDict: [String: Any] = ["field": aggregation.field,
                                                  "precision": aggregation.params?.precision ?? 0]
            
           
            let geoCentroidDict: [String: Any] = ["geo_centroid": ["field": aggregation.field]]
            let geoCentroidId = String(((Int(aggregation.id) ?? 0) + 1))
            idDict["geohash_grid"] = geoHashGridDict
            idDict["aggs"] = [geoCentroidId: geoCentroidDict]
            
            let aggsDict = [aggregation.id : idDict]
            
            var filterAggDict: [String: Any] = ["aggs": aggsDict]
            var boundingBoxDict: [String: Any] = ["ignore_unmapped": true]
            let locationDict:[String: Any] =  ["top_left": ["lat": 90, "lon": -180],
                                       "bottom_right": ["lat": -90, "lon": 180]]
            boundingBoxDict["location"] = locationDict
            let filterDict = ["geo_bounding_box": boundingBoxDict]
            filterAggDict["filter"] = filterDict
            idAggs["filter_agg"] = filterAggDict
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
    
    func addMetricAggsIfRequired(_ index: Int) -> [String: Any]? {
        guard index == otherAggregationList.count - 1,
        let metricAggs = aggregationsArray.filter({ $0.schema == "metric" && $0.metricType != .count }).first else {
            return nil
        }
        return createMetricAggregationFor(metricAggs)
    }
    
    func createMetricAggregationFor(_ aggregation: AggregationService) -> [String: Any] {
        let dict = ["\(aggregation.metricType.rawValue)": ["field": "\(aggregation.field)"]]
        return ["\(aggregation.id)": dict]
    }
}
