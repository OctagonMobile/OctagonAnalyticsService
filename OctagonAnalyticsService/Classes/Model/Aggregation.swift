//
//  Aggregation.swift
//  Alamofire
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

//MARK: Public
public enum MetricType: String {
    case unKnown        =   "unKnown"
    case count          =   "count"
    case sum            =   "sum"
    case uniqueCount    =   "unique_count"
    case topHit         =   "top_hits"
    case max            =   "max"
    case min            =   "min"
    case average        =   "avg"
    case median         =   "median"
    
    var displayValue: String {
        switch self {
        case .count: return "Count"
        case .sum: return "Sum of"
        case .topHit: return "Last"
        case .max: return "Max"
        case .min: return "Min"
        case .average: return "Average"
        case .median: return "50th Percentile of"
        case .uniqueCount: return "Unique Count of"
        case .unKnown: return ""
        }
    }
}

public enum BucketType: String {
    case unKnown            =   "unKnown"
    case dateHistogram      =   "date_histogram"
    case histogram          =   "histogram"
    case range              =   "range"
    case dateRange          =   "date_range"
    case ipv4Range          =   "ipv4_range"
    case terms              =   "terms"
    case filters            =   "filters"
    case significantTerms   =   "significant_terms"
    case geohashGrid        =   "geohash_grid"

}

public enum AggregationId: String {
    case unKnown        = "0"
    case bucket         = "2"
}

public enum AggregateFunction: String {
    case average
    case max
    case min
    case sum
    case unknown
}

public enum IntervalType: String {
    case unKnown        =   "unKnown"
    case auto           =   "auto"
    case millisecond    =   "ms"
    case second         =   "s"
    case minute         =   "m"
    case hourly         =   "h"
    case daily          =   "d"
    case weekly         =   "w"
    case monthly        =   "M"
    case yearly         =   "y"
    case custom         =   "custom"

    static var customTypes: [IntervalType] {
        return [.millisecond, .second, .minute, .hourly,
                .daily, .weekly, .monthly, .yearly]
    }
}


public extension Collection where Element == Double {
    func apply(aggregate: AggregateFunction) -> Double {
        switch aggregate {
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

public class Aggregation {

    public var id: String                      = ""
    public var schema: String                  = ""
    public var field: String                   = ""

    public var metricType: MetricType          = .unKnown
    public var bucketType: BucketType          = .unKnown
    
    public var params: AggregationParams?

    init(_ responseModel: AggregationResponse) {
        self.id         =   responseModel.id
        self.schema     =   responseModel.schema
        self.field      =   responseModel.params?.field ?? ""
        self.metricType =   responseModel.metricType
        self.bucketType =   responseModel.bucketType
        self.params     =   responseModel.params?.asUIModel()
    }
}

public class AggregationParams {
    
    public var precision: Int                  = 5
    public var interval: IntervalType          = IntervalType.unKnown
    public var customInterval: String          = ""
    public var intervalInt: Int                = 0
    public var aggregate: AggregateFunction    = .unknown

    init(_ responseModel: AggregationResponseParams) {
        self.precision      =   responseModel.precision ?? 5
        self.interval       =   responseModel.interval
        self.customInterval =   responseModel.customInterval ?? ""
        self.intervalInt    =   responseModel.intervalInt ?? 0
        self.aggregate      =   responseModel.aggregate
    }
}

//MARK: Private
class AggregationResponse : Decodable {

    var id: String                      = ""
    var enabled: Bool                   = true
    var schema: String                  = ""

    var metricType: MetricType          = .unKnown
    var bucketType: BucketType          = .unKnown
    
    var params: AggregationResponseParams?
    
    //MARK: Functions
    private enum CodingKeys: String, CodingKey {
        case id, enabled, schema, type, params
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        self.id         =   try container.decode(String.self, forKey: .id)
        self.enabled    =   try container.decode(Bool.self, forKey: .enabled)
        self.schema     =   try container.decode(String.self, forKey: .schema)
        self.params     =   try container.decode(AggregationResponseParams.self, forKey: .params)
        
        if let type = try? container.decode(String.self, forKey: .type) {
            if schema   ==  "metric" {
                metricType = MetricType(rawValue: type) ?? .unKnown
            } else {
                bucketType = BucketType(rawValue: type) ?? .unKnown
            }
        }
    }
    
    func asUIModel() -> Aggregation? {
        return Aggregation(self)
    }

}

class AggregationResponseParams: Decodable {
    
    var field: String?
    var precision: Int?
    var interval: IntervalType          = IntervalType.unKnown
    var customInterval: String?
    var intervalInt:Int?
    var aggregate: AggregateFunction    = .unknown
    
    private enum CodingKeys: String, CodingKey {
        case field, precision, interval, customInterval, aggregate
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        self.field          =   try? container.decode(String.self, forKey: .field)
        self.precision      =   try? container.decode(Int.self, forKey: .precision)
        self.customInterval =   try? container.decode(String.self, forKey: .customInterval)
        self.intervalInt    =   try? container.decode(Int.self, forKey: .interval)

        if let intrvlType  = try? container.decode(String.self, forKey: .interval) {
            self.interval = IntervalType(rawValue: intrvlType) ?? .unKnown
        }
        
        if let aggregateFunc = try? container.decode(String.self, forKey: .aggregate) {
            self.aggregate = AggregateFunction(rawValue: aggregateFunc) ?? .unknown
        }
    }
    
    func asUIModel() -> AggregationParams? {
        return AggregationParams(self)
    }
}
