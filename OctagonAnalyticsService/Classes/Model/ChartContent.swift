//
//  ChartContent.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public class ChartContent {
    public var key: String             =   ""
    public var bucketType: BucketType  =   .unKnown
    public var docCount                =   0.0
    public var bucketValue             =   0.0
    public var metricValue             =   0.0
    public var metricType: MetricType  =   .unKnown
    public var items: [Bucket]         =   []
    public var otherAggsCount: Int     =   0
    
    public var keyAsString: String {
        if bucketType == .dateHistogram {
            guard let keyValue = Int(key) else { return key }
            let date = Date(milliseconds: keyValue)
            return date.toFormat("YYYY-MM-dd HH:mm:ss")
        }
        return key
    }
    
    public var displayValue: Double {
        if bucketType == .range {
            return metricValue
        } else if metricType == .median {
            return bucketValue
        } else if metricType == .count || metricType == .uniqueCount {
            return docCount
        } else {
            return otherAggsCount > 1 ? metricValue : bucketValue
        }
    }
}
