//
//  ChartContent.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public class ChartContentService {
    public var key: String             =   ""
    public var bucketType: BucketType  =   .unKnown
    public var docCount                =   0.0
    public var bucketValue             =   0.0
    public var metricValue             =   0.0
    public var metricType: MetricType  =   .unKnown
    public var items: [BucketService]         =   []
    public var otherAggsCount: Int     =   0
    
}
