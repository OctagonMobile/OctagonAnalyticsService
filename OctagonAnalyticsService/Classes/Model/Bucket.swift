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
    
}
