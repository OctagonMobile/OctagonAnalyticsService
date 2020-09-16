//
//  VizDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 06/08/2020.
//

import Foundation

public class VizDataParams: VizDataParamsBase, OAErrorHandler {

    /// Interval is used only for Date Histogram
    public var interval: String?

    var otherAggregationList: [AggregationService] {
        return aggregationsArray.filter({ $0.schema != "metric" })
    }

    private var metricAggregationsList: [AggregationService] {
        return aggregationsArray.filter({ $0.schema == "metric"})
    }

    private var metricAggregation: AggregationService? {
        return metricAggregationsList.first
    }
    
    internal var size: Int {
        return 100
    }
    
    //MARK: Functions
    override func generatedQueryDataForVisualization(_ indexPatternName: String, params: VizDataParamsBase?) -> Data? {
        
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
                let isInverted = dict["isFilterInverted"] as? Bool ?? false
                
                isInverted ? mustNotFilters.append(filter) : mustFilters.append(filter)
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
             "size": size,
             "_source": [
               "excludes": []
             ],
             "aggs": params?.generatedAggregationJson() ?? [:],
             "script_fields": scriptedFieldObj,
             "timeout": "\(ServiceConfiguration.timeout)ms"
        ]
        
        let indexJsonString = indexJson.jsonStringRepresentation ?? ""
        let queryJSONString = queryJSON.jsonStringRepresentation ?? ""

        let finalContent = indexJsonString + "\n" + queryJSONString + "\n"
        return finalContent.data(using: .utf8)!
    }

    override func generatedAggregationJson() -> [String: Any] {
        
        if panelType == .gauge || panelType == .goal {
            guard let metricAggregation = metricAggregation else { return [:] }
            if metricAggregation.metricType == .count {
                return [:]
            }
            return createMetricAggregationFor(metricAggregation)
        }
        
        if panelType == .metric {
            var dict: [String: Any] = [:]
            
            if let _ = aggregationsArray.filter({ $0.schema == "group" }).first {
                dict = createAggsDictForAggregationAtIndex()
            } else {
                for metricAggs in metricAggregationsList {
                    guard metricAggs.metricType != .count else { continue }
                    let metricDict = createMetricAggregationFor(metricAggs)
                    dict[metricAggs.id] = metricDict[metricAggs.id]
                }
            }
            return dict
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
                    let orderBy = aggregation.params?.orderBy == "_key" ? "_key": "_count"
                    internalDict["order"] = ["\(orderBy)":"\(order)"]
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
        case .dateRange:
            
            var internalDict: [String: Any] = ["field": "\(aggregation.field)"]
            
            var list: [[String: Any]] = []
            for dateRangeList in aggregation.params?.dateRangesList ?? [] {
                let rangeListDict = ["from": dateRangeList.from, "to": dateRangeList.to]
                list.append(rangeListDict)
            }
            internalDict["ranges"] = list

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
                if panelType == .pieChart || panelType == .table {
                    var currentAggsDict: [String: Any]? = [:]
                    if let metricDict = dict["aggs"] as? [String: Any] {
                        currentAggsDict = metricDict
                    }
                    
                    let aggDict = createAggsDictForAggregationAtIndex(aggIndex)
                    for (key, value) in aggDict {
                        currentAggsDict?[key] = value
                    }
                    dict["aggs"] = currentAggsDict
                } else {
                    dict["aggs"] = createAggsDictForAggregationAtIndex(aggIndex)
                }
                idAggs[previousAggregation.id] = dict
            }
        }
        return idAggs
    }
    
    func addMetricAggsIfRequired(_ index: Int) -> [String: Any]? {
        guard (index == otherAggregationList.count - 1 || panelType == .pieChart || panelType == .table),
        let metricAggs = aggregationsArray.filter({ $0.schema == "metric" && $0.metricType != .count }).first else {
            return nil
        }
        return createMetricAggregationFor(metricAggs)
    }
    
    func createMetricAggregationFor(_ aggregation: AggregationService) -> [String: Any] {
        var dict = [String: Any]()
        if aggregation.metricType == .topHit {
            dict = ["\(aggregation.metricType.rawValue)":
                ["docvalue_fields" : [["field": "\(aggregation.field)"]],
                 "sort":[aggregation.params?.sortField: ["order": aggregation.params?.sortOrder]]]]
        } else if aggregation.metricType == .median {
            dict = ["percentiles": ["field": "\(aggregation.field)", "percents": [50], "keyed": false]]
        } else {
            dict = ["\(aggregation.metricType.rawValue)": ["field": "\(aggregation.field)"]]
        }
        return ["\(aggregation.id)": dict]
    }
    
    override func postResponseProcedure(_ response: Any) -> Any? {
        let error = parseResponseForError(response as? [String : Any])
        guard error == nil else {
            return error
        }
        
        if panelType == .metric {
            
            guard let result = response as? [String: Any] else { return response }
            var responseContent = (result["responses"] as? [[String: Any]])?.first
            
            var aggregationsList: [[String: Any]] = []

            if let groupAggs = aggregationsArray.filter({ $0.schema == "group" }).first {
                let aggregationsDict = responseContent?["aggregations"] as? [String: Any]
                var buckets = (aggregationsDict?[groupAggs.id] as? [String: Any])?["buckets"] as? [[String: Any]]
                if groupAggs.bucketType == .range {
                    let aggDict = (aggregationsDict?[groupAggs.id] as? [String: Any])
                    let bucketsDict = aggDict?["buckets"] as? [String: [String: Any]]
                    buckets = bucketsDict?.values.map { return $0 }
                }
                for bucket in buckets ?? [] {
                    
                    for metricAggs in metricAggregationsList {
                        var metricDict: [String: Any] = [:]

                        if metricAggs.metricType == .count {
                            metricDict["value"] = bucket["doc_count"] as? Double
                        } else if metricAggs.metricType == .topHit {
                            metricDict["value"] = parseTopHitValue(dict: bucket, metricAgg: metricAggs)
                        } else if let metricAggDict =  bucket["\(metricAggs.id)"] as? [String: [[String : Any]]], let valuesDict = metricAggDict["values"]?.first {
                            metricDict["value"] = valuesDict["value"]
                        } else {
                            metricDict["value"] = (bucket["\(metricAggs.id)"] as? [String: Any])?["value"] as? Double
                        }
                        
                        metricDict["type"] = metricAggs.metricType.rawValue
                        metricDict["id"] = metricAggs.id
                        if groupAggs.bucketType == .dateHistogram {
                            if let milliSec = bucket["key"] as? Int {
                                let format = groupAggs.params?.interval == .yearly ? "yyyy" : "yyyy-MM-dd"
                                metricDict["label"] = Date(milliseconds: milliSec).toFormat(format)
                            }
                        } else if groupAggs.bucketType == .range {
                             metricDict["label"] = "\(bucket["from"] ?? "") to \(bucket["to"] ?? "")"
                        }  else {
                            let labelText = bucket["key"] as? String
                            metricDict["label"] = labelText != nil ? labelText : "\(bucket["key"] ?? "")"
                        }
                        aggregationsList.append(metricDict)
                    }
                }
            } else {
                for metricAggs in metricAggregationsList {
                    
                    var metricDict: [String: Any] = [:]
                    if metricAggs.metricType == .count {
                        metricDict["value"] = (responseContent?["hits"] as? [String: Any])?["total"] ?? 0.0
                    } else if metricAggs.metricType == .topHit {
                        if let metricAggDict =  (responseContent?["aggregations"] as? [String: Any]) {
                            metricDict["value"] = parseTopHitValue(dict: metricAggDict, metricAgg: metricAggs)
                        }
                    } else if let metricAggDict =  (responseContent?["aggregations"] as? [String: Any])?["\(metricAggs.id)"] as? [String: [[String : Any]]], let valuesDict = metricAggDict["values"]?.first {
                        metricDict["value"] = valuesDict["value"]
                    } else {
                        let content = (responseContent?["aggregations"] as? [String: Any])?["\(metricAggs.id)"] as? [String: Any]
                        metricDict["value"] = content?["value"] as? Double ?? 0.0
                    }
                    
                    metricDict["type"] = metricAggs.metricType.rawValue
                    metricDict["id"] = metricAggs.id
                    metricDict["label"] = metricAggs.metricType.displayValue

                    aggregationsList.append(metricDict)
                }
            }
            
            responseContent?["aggregations"] = ["metrics": aggregationsList]
            return ["responses": [responseContent]]

        }
        return response
    }
    
    func parseTopHitValue(dict: [String: Any], metricAgg: AggregationService) -> Double {

        let firstMetricId = metricAgg.id
        var values: [Double] = []
        if let firstAgg = dict[firstMetricId] as? [String: Any],
            let hitsDict = firstAgg["hits"] as? [String : Any],
            let hitsArray = hitsDict["hits"] as? [[String: Any]] {
            for hit in hitsArray {
                if let source = hit["_source"] as? [String: Any],
                    let value = source[metricAgg.field] as? Double {
                    values.append(value)
                }
            }
        }
        
        if let aggregate = metricAgg.params?.aggregate {
            let value = values.applyAggregate(aggregate)
            return  Double(round(100*value)/100)
        }
        
        return 0
    }
}

extension Collection where Element == Double {
    func applyAggregate(_ fn: AggregateFunction) -> Double {
        switch fn {
        case .average:
            return reduce(0, +) / Double(count)
        case .max:
            return self.max() ?? 0.0
        case .min:
            return self.min() ?? 0.0
        case .sum:
            return reduce(0, +)
        case .unknown:
            return 0.0
        }
    }
}
