//
//  MapVisState.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public class MapVisStateService: VisStateService {
    
    public var mapUrl: String {
        return mapUrl_l
    }
    
    public var version: String         = ""

    public var transparent: Bool       = true
    
    public var styles: String          = ""

    public var format: String          = ""

    public var defaultLayerName: String          = ""

    /// This field is used in MapTracking Panel (Filtering key)
    public var userField: String          = ""
    public var locationField: String      = ""
    public var timeField: String          = ""
    public var faceUrl: String            = ""

    public var mapType: MapType        = .unknown
    
    public var mapLayers:  [MapLayerService]      =   []

    private var mapUrl_l: String      =       ""

    //MARK: Functions
    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        
        guard let visstateBaseModel = responseModel.visStateBase else { return }

        self.mapUrl_l       =   visstateBaseModel.params?.wms?.url ?? ""
        self.version        =   visstateBaseModel.params?.wms?.options?.version ?? ""
        self.transparent    =   visstateBaseModel.params?.wms?.options?.transparent ?? true
        self.styles         =   visstateBaseModel.params?.wms?.options?.styles ?? ""
        self.format         =   visstateBaseModel.params?.wms?.options?.format ?? ""
        self.defaultLayerName    =   visstateBaseModel.params?.wms?.options?.defaultLayerName ?? ""
        self.userField      =   visstateBaseModel.params?.userField ?? ""
        self.locationField  =   visstateBaseModel.params?.locationField ?? ""
        self.timeField      =   visstateBaseModel.params?.timeField ?? ""
        self.faceUrl        =   visstateBaseModel.params?.faceUrlMap ?? ""
        self.mapType        =   visstateBaseModel.params?.mapType ?? .unknown
        self.mapLayers      =   visstateBaseModel.params?.mapLayers?.compactMap({ $0.asUIModel() }) ?? []
    }
}

extension MapVisStateService {
        
    public enum MapType: String {
        case unknown                =   "Unknown"
        case heatMap                =   "Heatmap"
        case scaledCircleMarkers    =   "Scaled Circle Markers"
        case shadedCircleMarkers    =   "Shaded Circle Markers"
        case shadedGeohashGrid      =   "Shaded Geohash Grid"
    }
}

public class MapLayerService {
    
    public var layerName: String       =   ""
    public var buttonTitle: String     =   ""

    //MARK: Functions
    init(_ responseModel: MapLayerResponse) {
        self.layerName      =   responseModel.layerName ?? ""
        self.buttonTitle    =   responseModel.buttonTitle ?? ""

    }

}
