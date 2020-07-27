//
//  Metric.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public class Metric {
    public var id: String       = ""
    public var type: String     = ""
    public var value: NSNumber  = NSNumber(value: 0)
    private var labelStr: String?
    private var labelInt: Int?
    public var label: String {
        if let str = labelStr, !str.isEmpty {
            return str
        } else if let int = labelInt, int > 0 {
            return String(int)
        } else {
            return ""
        }
    }
    public weak var panel: MetricPanel?
    
    public var computedLabel: String {
        var computed = label
        let filteredMetric = panel?.visState?.metricAggregationsArray.filter { $0.id == id }

        guard let metric = filteredMetric?.first,
            panel?.visState?.otherAggregationsArray.isEmpty == false else {
            return computed
        }
        
        computed += "-" + metric.metricType.displayValue
        
        if metric.field.isEmpty == false {
            computed += " " + metric.field
        }
        
        return computed
    }
    
    //MARK: Functions
    
//    func mapping(map: Map) {
//        id              <- map[MetricConstant.id]
//        type            <- map[MetricConstant.type]
//        labelStr        <- map[MetricConstant.label]
//        labelInt        <- map[MetricConstant.label]
//        value           <- map[MetricConstant.value]
//    }

}
