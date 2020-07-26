//
//  ChartContent.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public class ChartContent {
    var key: String             =   ""
    var bucketType: BucketType  =   .unKnown
    var docCount                =   0.0
    var bucketValue             =   0.0
    var metricValue             =   0.0
    var metricType: MetricType  =   .unKnown
    var items: [Bucket]         =   []
    var otherAggsCount: Int     =   0
    
    var keyAsString: String {
        if bucketType == .dateHistogram {
            guard let keyValue = Int(key) else { return key }
            let date = Date(milliseconds: keyValue)
            return date.toFormat("YYYY-MM-dd HH:mm:ss")
        }
        return key
    }
    
    var displayValue: Double {
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

//This extension is used temporary purpose
extension Date {

    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func toFormat(_ format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.locale = Locale.current
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }

}
