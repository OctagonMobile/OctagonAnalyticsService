//
//  VisState.swift
//  Alamofire
//
//  Created by Rameez on 23/07/2020.
//

import Foundation

public class VisState {
    public var title: String
    public var type: PanelType

    public var aggregationsArray: [Aggregation]         = []
    public var metricAggregationsArray: [Aggregation]   = []
    public var segmentSchemeAggregation: Aggregation?
    public var otherAggregationsArray: [Aggregation]    = []

    public var xAxisPosition: AxisPosition  =   .bottom
    public var seriesMode: SeriesMode       =   .stacked

    init(_ responseModel: VisStateBase) {
        self.title  =   responseModel.title
        self.type   =   responseModel.type
        self.xAxisPosition  =   responseModel.params.categoryAxes?.first?.position ?? .bottom
        self.seriesMode     =   responseModel.params.seriesParams?.first?.mode ?? .stacked
        
        self.aggregationsArray  =   responseModel.aggregationsArray.compactMap({ $0.asUIModel() })
        
        self.metricAggregationsArray    = aggregationsArray.filter({ $0.schema == "metric"})
        self.otherAggregationsArray     = aggregationsArray.filter({ $0.schema != "metric"})
        self.segmentSchemeAggregation   = otherAggregationsArray.filter({ $0.schema == "segment"}).first
    }
    
    public enum AxisPosition: String {
        case left   =   "left"
        case right  =   "right"
        case top    =   "top"
        case bottom =   "bottom"
    }
    
    public enum SeriesMode: String {
        case normal   =   "normal"
        case stacked  =   "stacked"
    }
}

//MARK: VisState
class VisStateHolderBase: Decodable {
    
    var visStateBase: VisStateBase?
    
    private enum CodingKeys: String, CodingKey {
        case attributes
        enum AttributesCodingKeys: String, CodingKey {
            case visState
        }
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        let attributesContainer = try container.nestedContainer(keyedBy: CodingKeys.AttributesCodingKeys.self, forKey: .attributes)
       
        let json = try attributesContainer.decode(String.self, forKey: .visState)
        if let data = json.data(using: .utf8) {
            self.visStateBase = try JSONDecoder().decode(VisStateBase.self, from: data)
        }
    }
    
    func asUIModel() -> VisState? {
        if let content = self.visStateBase {
            return  VisState(content)
        }
        return nil
    }
}

class VisStateBase: Decodable {
    var title: String
    var type: PanelType
    var params: VisStateParams
    var aggregationsArray: [AggregationResponse] = []

    private enum CodingKeys: String, CodingKey {
        case title, type, params, aggs
    }
    
    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        self.title      =   try container.decode(String.self, forKey: .title)
        
        let panelType = try container.decode(String.self, forKey: .type)
        self.type   =   PanelType(rawValue: panelType) ?? .unKnown

        self.params      =   try container.decode(VisStateParams.self, forKey: .params)
        self.aggregationsArray  =   try container.decode([AggregationResponse].self, forKey: .aggs)
    }
    
}

class VisStateParams: Decodable {

    var seriesParams: [SeriesParams]?
    var categoryAxes: [CategoryAxes]?

    private enum CodingKeys: String, CodingKey {
        case seriesParams, categoryAxes
    }
    
    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        self.seriesParams   =   try? container.decode([SeriesParams].self, forKey: .seriesParams)
        self.categoryAxes   =   try? container.decode([CategoryAxes].self, forKey: .categoryAxes)

    }
    
}

class SeriesParams: Decodable {
    
    var mode: VisState.SeriesMode?
    
    private enum CodingKeys: String, CodingKey {
        case mode
    }

    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        if let sMode = try? container.decode(String.self, forKey: .mode) {
            self.mode = VisState.SeriesMode(rawValue: sMode)
        }
    }
}


class CategoryAxes: Decodable {
    
    var position: VisState.AxisPosition?

    private enum CodingKeys: String, CodingKey {
        case position
    }

    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        if let aPosition = try? container.decode(String.self, forKey: .position) {
            self.position = VisState.AxisPosition(rawValue: aPosition)
        }
    }
}
