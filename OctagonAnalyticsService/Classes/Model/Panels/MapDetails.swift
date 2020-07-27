//
//  MapDetails.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation
import CoreLocation

public class MapDetails: ChartContent {
   
    public var location: CLLocation?
    
    public var type: String        = ""
    
    //MARK: Functions
//    func mapping(map: Map) {
//        if let keyValue = map.JSON[BucketConstant.key] {
//            key   = "\(keyValue)"
//        }
//        docCount            <- map[BucketConstant.docCount]
//        bucketValue         <- map[BucketConstant.bucketValue]
//
//        type <- map[BucketConstant.type]
//
//        if let locationDict = map.JSON[MapDetailsConstant.location] as? [String: Any] {
//            let lat = locationDict[MapDetailsConstant.lat] as? Double ?? 0.0
//            let longitude = locationDict[MapDetailsConstant.long] as? Double ?? 0.0
//
//            location = CLLocation(latitude: lat, longitude: longitude)
//        }
//
//    }

}
