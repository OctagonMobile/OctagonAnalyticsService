//
//  MapVizParams.swift
//  OctagonAnalyticsService
//
//  Created by Kishore Kumar on 8/25/20.
//

import UIKit

public struct MapParamLocation {
    public let lat: Double
    public let lon: Double
}

public class MapVizParams: VizDataParams {
    public var topLeftLocation: MapParamLocation = MapParamLocation(lat: 90, lon: -180)
    public var bottomRightLocation: MapParamLocation = MapParamLocation(lat: -90, lon: 180)
    
    override func createAggsDictForAggregationAtIndex(_ index: Int = 0) -> [String : Any] {
        guard index < otherAggregationList.count else { return [:] }
        let aggregation = otherAggregationList[index]
        var idAggs: [String: Any] = [:]
        
        var idDict = [String: Any]()
        let geoHashGridDict: [String: Any] = ["field": aggregation.field,
                                              "precision": aggregation.params?.precision ?? 0]
        
        
        let geoCentroidDict: [String: Any] = ["geo_centroid": ["field": aggregation.field]]
        let geoCentroidId = String(((Int(aggregation.id) ?? 0) + 1))
        idDict["geohash_grid"] = geoHashGridDict
        idDict["aggs"] = [geoCentroidId: geoCentroidDict]
        
        let aggsDict = [aggregation.id : idDict]
        
        var filterAggDict: [String: Any] = ["aggs": aggsDict]
        var boundingBoxDict: [String: Any] = ["ignore_unmapped": true]
        let locationDict:[String: Any] =  ["top_left": ["lat": topLeftLocation.lat, "lon": topLeftLocation.lon],
                                           "bottom_right": ["lat": bottomRightLocation.lat, "lon": bottomRightLocation.lon]]
        boundingBoxDict[aggregation.field] = locationDict
        let filterDict = ["geo_bounding_box": boundingBoxDict]
        filterAggDict["filter"] = filterDict
        idAggs["filter_agg"] = filterAggDict
        return idAggs
    }
}
