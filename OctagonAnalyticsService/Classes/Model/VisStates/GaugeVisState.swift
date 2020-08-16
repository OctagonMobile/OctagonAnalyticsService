//
//  GaugeVisState.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public class GaugeVisStateService: VisStateService {
    public enum GaugeType: String {
        case gauge      =   "gauge"
        case goal       =   "goal"
    }
    
    public var gaugeType: GaugeType    =   .gauge
    public var gauge: GaugeService?
    
    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        
        guard let visstateBaseModel = responseModel.visStateBase else { return }
        self.gaugeType  =   GaugeType(rawValue: visstateBaseModel.type.rawValue) ?? .gauge
        self.gauge      =   visstateBaseModel.params?.gauge?.asUIModel()
    }
}

public class GaugeService {
    
    public enum GaugeSubType: String {
        case arc    =   "Arc"
        case circle =   "Circle"
    }

    public var ranges: [GaugeRangeService] =   []
    
    public var subType: GaugeSubType  =   .arc
    
    //MARK: Functions
    init(_ responseModel: GaugeResponse) {
        self.subType    =   responseModel.subType ?? .arc
        self.ranges     =   responseModel.ranges?.compactMap({ $0.asUIModel() }) ?? []
    }
}

public class GaugeRangeService {
    
    public var from: CGFloat   =   0.0
    public var to: CGFloat     =   0.0

    init(_ responseModel: GaugeRangeResponse) {
        self.from   =   responseModel.from ?? 0.0
        self.to     =   responseModel.to ?? 0.0
    }
}
