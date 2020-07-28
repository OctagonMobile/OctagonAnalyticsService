//
//  VisState.swift
//  Alamofire
//
//  Created by Rameez on 23/07/2020.
//

import Foundation

public class VisStateService {
    public var title: String
    public var type: PanelType

    public var aggregationsArray: [AggregationService]         = []
    public var metricAggregationsArray: [AggregationService]   = []
    public var segmentSchemeAggregation: AggregationService?
    public var otherAggregationsArray: [AggregationService]    = []

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
class VisStateContainer: Decodable, ParseJsonArrayProtocol {

    var visStateHolder: [VisStateHolderBase]?
    private enum CodingKeys: String, CodingKey {
        case savedObjects  =   "saved_objects"
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)

        if let jsonArray: [[String: Any]] = try container.decode(Array<Any>.self, forKey: .savedObjects) as? [[String: Any]] {
            self.visStateHolder = try parse(jsonArray, type: ServiceConfiguration.version.visStateModel.self)
        }
    }
}

class VisStateHolderBase: Decodable {
    
    var id:String
    
    var visStateBase: VisStateBase?
    
    private enum CodingKeys: String, CodingKey {
        case id, attributes
        enum AttributesCodingKeys: String, CodingKey {
            case visState
        }
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id     =   try container.decode(String.self, forKey: .id)
        let attributesContainer = try container.nestedContainer(keyedBy: CodingKeys.AttributesCodingKeys.self, forKey: .attributes)
       
        let json = try attributesContainer.decode(String.self, forKey: .visState)
        if let data = json.data(using: .utf8) {
            self.visStateBase = try JSONDecoder().decode(VisStateBase.self, from: data)
        }
    }
    
    func asUIModel() -> VisStateService? {
        guard let content = self.visStateBase else { return nil }
        switch content.type {
        case .pieChart:                 return PieChartVisStateService(content)
        case .tagCloud, .t4pTagcloud:   return TagCloudVisStateService(content)
        case .tile:                     return TileVisStateService(content)
        case .metric:                   return MetricVisStateService(content)
        case .heatMap, .mapTracking:    return MapVisStateService(content)
        case .neo4jGraph:               return GraphVisStateService(content)
        case .html:                     return WebContentVisStateService(content)
        case .markdown:                 return MarkDownVisStateService(content)
        case .gauge, .goal:             return GaugeVisStateService(content)
        case .inputControls:            return InputControlsVisStateService(content)
        default:
            return VisStateService(content)
        }
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
    
    func asUIModel() -> VisStateService? {
        return VisStateService(self)
    }
}

class VisStateParams: Decodable {

    var seriesParams: [SeriesParams]?
    var categoryAxes: [CategoryAxes]?
    
    // WebContent Visstate
    var html: String?

    //TagCloud
    var minFontSize: NSInteger?
    var maxFontSize: NSInteger?

    //MarkDownVisState
    var markdownText: String?
    var fontSize: CGFloat?

    //PieChartVisState
    var isDonut: Bool?
    
    //TileVisState
    var imageHashField: String?
    var maxDistance: Int?
    var containerId: Int?

    //GraphVisState
    var query: String?
    var nodeImageBaseUrl: String?
    var nodeImageProperty: String?

    //MapVisState
    var wms: WmsParams?
    var userField: String?
    var mapType: MapVisStateService.MapType?
    var mapLayers: [MapLayerResponse]?
    
    //GaugeVisState
    var gaugeType: GaugeVisStateService.GaugeType?
    var gauge: GaugeResponse?
    
    //InputControlsVisState
    var controls: [ControlsResponse]?
    
    private enum CodingKeys: String, CodingKey {
        case seriesParams, categoryAxes,
        html,
        minFontSize, maxFontSize,
        markdown, fontSize,
        isDonut,
        imageHashField, maxDistance, containerId,
        query, node_image_base_url, node_image_property,
        wms, user_field, mapType, quickButtons,
        type, gauge,
        controls
    }
    
    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        self.seriesParams   =   try? container.decode([SeriesParams].self, forKey: .seriesParams)
        self.categoryAxes   =   try? container.decode([CategoryAxes].self, forKey: .categoryAxes)

        self.html   = try? container.decode(String.self, forKey: .html)
        
        self.minFontSize   = try? container.decode(NSInteger.self, forKey: .minFontSize)
        self.maxFontSize   = try? container.decode(NSInteger.self, forKey: .maxFontSize)

        self.markdownText   = try? container.decode(String.self, forKey: .markdown)
        self.fontSize       = try? container.decode(CGFloat.self, forKey: .fontSize)
        
        self.isDonut        =   try? container.decode(Bool.self, forKey: .isDonut)

        self.imageHashField = try? container.decode(String.self, forKey: .imageHashField)
        self.maxDistance    = try? container.decode(Int.self, forKey: .maxDistance)
        self.containerId    = try? container.decode(Int.self, forKey: .containerId)
        
        self.query              = try? container.decode(String.self, forKey: .query)
        self.nodeImageBaseUrl   = try? container.decode(String.self, forKey: .node_image_base_url)
        self.nodeImageProperty  = try? container.decode(String.self, forKey: .node_image_property)
        
        self.wms    =   try? container.decode(WmsParams.self, forKey: .wms)
        self.userField  =   try? container.decode(String.self, forKey: .user_field)
        self.mapLayers  =   try? container.decode([MapLayerResponse].self, forKey: .quickButtons)
        if let type = try? container.decode(String.self, forKey: .mapType) {
            self.mapType    =   MapVisStateService.MapType(rawValue: type)
        }
        
        self.gauge  =   try? container.decode(GaugeResponse.self, forKey: .gauge)
        if let type = try? container.decode(String.self, forKey: .type) {
            self.gaugeType  =   GaugeVisStateService.GaugeType(rawValue: type)
        }
        
        self.controls   =   try? container.decode([ControlsResponse].self, forKey: .controls)
    }
    
}

class SeriesParams: Decodable {
    
    var mode: VisStateService.SeriesMode?
    
    private enum CodingKeys: String, CodingKey {
        case mode
    }

    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        if let sMode = try? container.decode(String.self, forKey: .mode) {
            self.mode = VisStateService.SeriesMode(rawValue: sMode)
        }
    }
}


class CategoryAxes: Decodable {
    
    var position: VisStateService.AxisPosition?

    private enum CodingKeys: String, CodingKey {
        case position
    }

    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        if let aPosition = try? container.decode(String.self, forKey: .position) {
            self.position = VisStateService.AxisPosition(rawValue: aPosition)
        }
    }
}

//MARK: Map VisState
class WmsParams: Decodable {
    var url: String?
    var wms: WmsParams?
    var options: Options?

    private enum CodingKeys: String, CodingKey {
        case url, wms, options
    }
    
    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        self.url   = try? container.decode(String.self, forKey: .url)
        self.wms   = try? container.decode(WmsParams.self, forKey: .wms)
        self.options    =   try? container.decode(Options.self, forKey: .options)
    }
    
    // Options Class
    class Options: Decodable {
        var version: String?
        var transparent: Bool?
        var styles: String?
        var format: String?
        var defaultLayerName: String?

        private enum CodingKeys: String, CodingKey {
            case version, transparent, styles, format, layers
        }
        
        required init(from decoder: Decoder) throws {
            let container   =   try decoder.container(keyedBy: CodingKeys.self)
            
            self.version   = try? container.decode(String.self, forKey: .version)
            self.transparent   = try? container.decode(Bool.self, forKey: .transparent)
            self.styles     =   try? container.decode(String.self, forKey: .styles)
            self.format     =   try? container.decode(String.self, forKey: .format)
            self.defaultLayerName     =   try? container.decode(String.self, forKey: .layers)
        }
    }
}

class MapLayerResponse: Decodable {
    
    var layerName: String?
    var buttonTitle: String?


    private enum CodingKeys: String, CodingKey {
        case label, layers
    }
    
    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        self.layerName      = try? container.decode(String.self, forKey: .label)
        self.buttonTitle    = try? container.decode(String.self, forKey: .layers)
    }
    
    func asUIModel() -> MapLayerService? {
        return MapLayerService(self)
    }
}

//MARK: Gauage VisState
class GaugeResponse: Decodable {
    var subType: GaugeService.GaugeSubType?
    
    var ranges: [GaugeRangeResponse]?
    
    private enum CodingKeys: String, CodingKey {
        case gaugeType, colorsRange
    }

    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        if let type = try? container.decode(String.self, forKey: .gaugeType) {
            self.subType    =   GaugeService.GaugeSubType(rawValue: type)
        }
        
        self.ranges =   try? container.decode([GaugeRangeResponse].self, forKey: .colorsRange)
    }
    
    func asUIModel() -> GaugeService? {
        return GaugeService(self)
    }
}

class GaugeRangeResponse: Decodable {
    
    var from: CGFloat?
    var to: CGFloat?

    private enum CodingKeys: String, CodingKey {
        case from, to
    }

    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        self.from   =   try? container.decode(CGFloat.self, forKey: .from)
        self.to     =   try? container.decode(CGFloat.self, forKey: .to)
    }
    
    func asUIModel() -> GaugeRangeService? {
        return GaugeRangeService(self)
    }

}

//MARK: Gauage VisState
class ControlsResponse: Decodable {
    
    var fieldName: String?
    var id: String?
    var indexPattern: String?
    var label: String?
    var parent: String?
    var type: ControlService.ControlType?
    
    var options: Options?
    

    private enum CodingKeys: String, CodingKey {
        case fieldName, id, indexPattern, label, parent, type, options
    }

    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        
        self.fieldName  =   try? container.decode(String.self, forKey: .fieldName)
        self.id         =   try? container.decode(String.self, forKey: .id)
        self.indexPattern  =   try? container.decode(String.self, forKey: .indexPattern)
        self.label      =   try? container.decode(String.self, forKey: .label)
        self.parent     =   try? container.decode(String.self, forKey: .parent)

        if let type = try? container.decode(String.self, forKey: .type) {
            self.type   =   ControlService.ControlType(rawValue: type)
        }
        
        self.options    =   try? container.decode(Options.self, forKey: .options)
    }
    
    func asUIModel() -> ControlService? {
        return ControlService(self)
    }

    
    class Options: Decodable {
        
        var dynamicOptions: Bool?
        var multiSelect: Bool?
        var order: String?
        var size: Int?
        var type: String?

        var decimalPlaces: Int?
        var step: Int?
        
        private enum CodingKeys: String, CodingKey {
            case dynamicOptions, multiselect, order, size, type,
            decimalPlaces, step
        }

        required init(from decoder: Decoder) throws {
            let container   =   try decoder.container(keyedBy: CodingKeys.self)
            
            self.dynamicOptions =   try? container.decode(Bool.self, forKey: .dynamicOptions)
            self.multiSelect    =   try? container.decode(Bool.self, forKey: .multiselect)
            self.order          =   try? container.decode(String.self, forKey: .order)
            self.size           =   try? container.decode(Int.self, forKey: .size)
            self.type           =   try? container.decode(String.self, forKey: .type)
            
            self.decimalPlaces  =   try? container.decode(Int.self, forKey: .decimalPlaces)
            self.step           =   try? container.decode(Int.self, forKey: .step)
        }
    }
}
