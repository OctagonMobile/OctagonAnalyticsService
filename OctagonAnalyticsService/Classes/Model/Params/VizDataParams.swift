//
//  VizDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 06/08/2020.
//

import Foundation

public class VizDataParams: VizDataParamsBase {

    /// Interval is used only for Date Histogram
    public var interval: String?

    var otherAggregationList: [AggregationService] {
        return aggregationsArray.filter({ $0.schema != "metric" })
    }

    private var metricAggregation: AggregationService? {
        return aggregationsArray.filter({ $0.schema == "metric"}).first
    }
    
    //MARK: Functions    
    override func generatedQueryDataForVisualization(_ indexPatternName: String, params: VizDataParamsBase?) -> Data? {
        
        let indexJson: [String: Any] = ["index": indexPatternName,
                                        "ignore_unavailable": true]
        
        
        var mustFilters: [[String: Any]] = []
        if let indexPattern = ServiceProvider.shared.indexPatternsList.filter({ $0.id == params?.indexPatternIdList.first}).first,
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

    override func generatedAggregationJson() -> [String: Any] {
        
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
