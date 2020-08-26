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
    
    /// ID of the IndexPattern to which the VisState/panel belong to
    public var indexPatternId: String?

    init(_ responseModel: VisStateHolderBase) {
        
        guard let visstateBaseModel = responseModel.visStateBase else {
            title   =   ""
            type    =   .unKnown
            return
        }
        
        self.title  =   visstateBaseModel.title
        self.type   =   visstateBaseModel.type
        self.xAxisPosition  =   visstateBaseModel.params?.categoryAxes?.first?.position ?? .bottom
        self.seriesMode     =   visstateBaseModel.params?.seriesParams?.first?.mode ?? .stacked
        
        self.aggregationsArray  =   visstateBaseModel.aggregationsArray.compactMap({ $0.asUIModel() })
        
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

//MARK: VisState Holder
class VisStateHolderBase: Decodable {
    
    var id:String
    var type: String
    
    var visStateBase: VisStateBase?
    
    var searchSourceJSON: String?
    
    public var searchQuery: String?

    // Followinf properties only for Saved Search
    var sortList: [String]  =   []
    var columns: [String]   =   []

    private enum CodingKeys: String, CodingKey {
        case id, type, attributes
        enum AttributesCodingKeys: String, CodingKey {
            case visState, title, kibanaSavedObjectMeta, sort, columns
            enum MetaDataCodingKeys: String, CodingKey {
                case searchSourceJSON
            }
        }
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        let attributesContainer = try container.nestedContainer(keyedBy: CodingKeys.AttributesCodingKeys.self, forKey: .attributes)
        let metaDataContainer = try attributesContainer.nestedContainer(keyedBy: CodingKeys.AttributesCodingKeys.MetaDataCodingKeys.self, forKey: .kibanaSavedObjectMeta)

        self.id     =   try container.decode(String.self, forKey: .id)
        self.type   =   try container.decode(String.self, forKey: .type)
        self.searchSourceJSON   =   try metaDataContainer.decode(String.self, forKey: .searchSourceJSON)
        
        if type == "search" {
            let title = try? attributesContainer.decode(String.self, forKey: .title)
            let customVisStateDict: [String: Any] = ["type": self.type, "title": title ?? ""]
            if let data = try? JSONSerialization.data(withJSONObject: customVisStateDict as Any, options: .prettyPrinted) {
                self.visStateBase = try JSONDecoder().decode(VisStateBase.self, from: data)
            }
            self.sortList = (try? attributesContainer.decode([String].self, forKey: .sort)) ?? []
            self.columns  = (try? attributesContainer.decode([String].self, forKey: .columns)) ?? []

        } else {
            let json = try attributesContainer.decode(String.self, forKey: .visState)
            if let data = json.data(using: .utf8) {
                self.visStateBase = try JSONDecoder().decode(VisStateBase.self, from: data)
            }
        }

    }
    
    func asUIModel() -> VisStateService? {
        guard let content = self.visStateBase else { return nil }
        switch content.type {
        case .pieChart:                 return PieChartVisStateService(self)
        case .tagCloud, .t4pTagcloud:   return TagCloudVisStateService(self)
        case .tile:                     return TileVisStateService(self)
        case .metric:                   return MetricVisStateService(self)
        case .heatMap, .mapTracking:    return MapVisStateService(self)
        case .neo4jGraph:               return GraphVisStateService(self)
        case .html:                     return WebContentVisStateService(self)
        case .markdown:                 return MarkDownVisStateService(self)
        case .gauge, .goal:             return GaugeVisStateService(self)
        case .inputControls:            return InputControlsVisStateService(self)
        default:
            return VisStateService(self)
        }
    }
}

class VisStateHolderBase654: VisStateHolderBase {
    
    override func asUIModel() -> VisStateService? {
        let visStateService = super.asUIModel()
        
        if let searchSourceJSON = searchSourceJSON,
            let data = searchSourceJSON.data(using: .utf8) {
            let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            visStateService?.indexPatternId = dict?["index"] as? String
            
            let queryDict = dict?["query"] as? [String: Any]
            self.searchQuery = queryDict?["query"] as? String
        }
        return visStateService
    }
}

class VisStateHolderBase732: VisStateHolderBase {
    
    var references: [References]    =   []
    private enum CodingKeys: String, CodingKey {
        case references
    }
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.references = try container.decode([References].self, forKey: .references)
    }
    
    override func asUIModel() -> VisStateService? {
        let visStateService = super.asUIModel()
        
        if let searchSourceJSON = searchSourceJSON,
            let data = searchSourceJSON.data(using: .utf8) {
            let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            let keyName = dict?["indexRefName"] as? String ?? ""
            visStateService?.indexPatternId = references.filter({$0.name == keyName}).first?.id
            
            let queryDict = dict?["query"] as? [String: Any]
            self.searchQuery = queryDict?["query"] as? String
        }
        return visStateService
    }
}

//MARK: VisState Baase
class VisStateBase: Decodable {
    var title: String
    var type: PanelType =   .unKnown
    var params: VisStateParams?
    var aggregationsArray: [AggregationResponse] = []

    private enum CodingKeys: String, CodingKey {
        case title, type, params, aggs
    }
    
    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        self.title      =   try container.decode(String.self, forKey: .title)
        
        if let panelType = try? container.decode(String.self, forKey: .type) {
            self.type   =   PanelType(rawValue: panelType) ?? .unKnown
        }

        self.params      =   try? container.decode(VisStateParams.self, forKey: .params)
        self.aggregationsArray  =   (try? container.decode([AggregationResponse].self, forKey: .aggs)) ?? []
    }
    
//    func asUIModel() -> VisStateService? {
//        return VisStateService(self)
//    }
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
    
    //Metrics
    var metric: Metric?
    
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
        controls,
        metric
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
        
        self.metric     =   try? container.decode(Metric.self, forKey: .metric)
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

//MARK: Metric VisState
class Metric: Decodable {
    var percentageMode: Bool?
    var useRanges: Bool?
    var fontSize: CGFloat?
    var subText: CGFloat?
    
    private enum CodingKeys: String, CodingKey {
        case percentageMode, useRanges, style
        enum StyleCodingKeys: String, CodingKey {
            case subText, fontSize
        }
    }

    required init(from decoder: Decoder) throws {
        let container   =   try decoder.container(keyedBy: CodingKeys.self)
        let styleDataContainer = try container.nestedContainer(keyedBy: CodingKeys.StyleCodingKeys.self, forKey: .style)

        self.percentageMode =   try? container.decode(Bool.self, forKey: .percentageMode)
        self.useRanges      =   try? container.decode(Bool.self, forKey: .useRanges)

        self.fontSize       =   try? styleDataContainer.decode(CGFloat.self, forKey: .fontSize)
        self.subText        =   try? styleDataContainer.decode(CGFloat.self, forKey: .subText)
    }
}
