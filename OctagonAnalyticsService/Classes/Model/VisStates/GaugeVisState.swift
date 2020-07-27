//
//  GaugeVisState.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public class GaugeVisState: VisState {
    public enum GaugeType: String {
        case gauge      =   "gauge"
        case goal       =   "goal"
    }
    
    public var gaugeType: GaugeType    =   .gauge
    public var gauge: Gauge?
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        
        self.gaugeType  =   responseModel.params.gaugeType ?? .gauge
        self.gauge      =   responseModel.params.gauge?.asUIModel()
    }
}

public class Gauge {
    
    public enum GaugeSubType: String {
        case arc    =   "Arc"
        case circle =   "Circle"
    }

    public var ranges: [GaugeRange] =   []
    
    public var subType: GaugeSubType  =   .arc
    
    //MARK: Functions
    init(_ responseModel: GaugeResponse) {
        self.subType    =   responseModel.subType ?? .arc
        self.ranges     =   responseModel.ranges?.compactMap({ $0.asUIModel() }) ?? []
    }
}

public class GaugeRange {
    
    public var from: CGFloat   =   0.0
    public var to: CGFloat     =   0.0

    init(_ responseModel: GaugeRangeResponse) {
        self.from   =   responseModel.from ?? 0.0
        self.to     =   responseModel.to ?? 0.0
    }
}
