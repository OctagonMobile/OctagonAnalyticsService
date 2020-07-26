//
//  Bucket.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public class Bucket {
    
    var key                     =   ""
    
    var docCount                =   0.0
    
    var bucketValue             =   0.0
    
    var metricValue             =   0.0
    
    var bucketType: BucketType  =   .unKnown
    var subAggsResult: AggResult?
    
}
