//
//  Bucket.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public class Bucket {
    
    public var key                     =   ""
    
    public var docCount                =   0.0
    
    public var bucketValue             =   0.0
    
    public var metricValue             =   0.0
    
    public var bucketType: BucketType  =   .unKnown
    public var subAggsResult: AggResult?
    
    public var displayValue: Double {
        let aggregationsCount = (visState?.otherAggregationsArray.count ?? 0)
        let metricType = visState?.metricAggregationsArray.first?.metricType ?? MetricType.unKnown
        let shouldShowBucketValue = (metricType == .sum || metricType == .max || metricType == .min || metricType == .average || metricType == .median || metricType == .topHit)

        //The condition (aggregation count == 1) is added because if there are more than 1 subbuckets present for the visualization then we should be showing the docCount/metricValue based on metricType or else we should show docCount/bucketValue based on metricType
        if bucketType == .range {
            return metricValue
        } else if aggregationsCount == 1 || metricType == .median || metricType == .topHit {
            return shouldShowBucketValue ? bucketValue : docCount
        } else {
            return (metricType == .count) ? docCount : metricValue
        }
    }

    public var parentBkt: Bucket? {
        return parentBucket
    }

    private var parentBucket: Bucket?
    private var visState: VisState?

    public var aggIndex: Int {
        var level = -1
        var tempBucket: Bucket? = self
        while tempBucket != nil {
            level += 1
            tempBucket = tempBucket?.parentBucket
        }
        return level
    }

}
