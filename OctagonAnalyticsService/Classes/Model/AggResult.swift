//
//  AggResult.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public typealias Legend = (text: String, color: UIColor)

public class AggResultService {
    
    public var buckets: [BucketService]           =   []
    private var colorIndex = 0
    private var colorsDict: [String: UIColor] = [:]
    public var chartLegends: [Legend] = []
}
