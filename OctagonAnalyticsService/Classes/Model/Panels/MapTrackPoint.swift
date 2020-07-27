//
//  MapTrackPoint.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import UIKit
import MapKit

public class MapTrackPoint: ChartContent {

    /// Timestamp
    public var timestamp: Date?
    
    /// Location
    public var location: CLLocation?
    
    /// User ID
    public var userField: String       =       ""
    
    /// Image Icon
    public var imageIconUrl: String    =       ""

    /// Returns Timestamp string in "YYYY-MM-dd HH:mm:ss.SSS" format
    public var timestampString: String {
        guard let timestamp = timestamp else { return "" }
        return timestamp.toFormat("YYYY-MM-dd HH:mm:ss")
    }
    
    //MARK:
//    func mapping(map: Map) {
//
//        if let keyValue = map.JSON["key"] {
//            key   = "\(keyValue)"
//        }
//        docCount            <- map["doc_count"]
//        bucketValue         <- map["bucketValue"]
//
//        userField       <-  map["userID"]
//        imageIconUrl    <-  map["faceUrl"]
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        if let dateString = map["timestamp"].currentValue as? String, let _date = dateFormatter.date(from: dateString) {
//            timestamp = _date
//        }
//
//        if let locationString = map.JSON["location"] as? String {
//            let coordinates = locationString.components(separatedBy: ",")
//            guard let latString = coordinates.first, let longitudeString = coordinates.last else { return }
//            let lat = CLLocationDegrees(latString) ?? 0.0
//            let longitude = CLLocationDegrees(longitudeString) ?? 0.0
//
//            location = CLLocation(latitude: lat, longitude: longitude)
//        }
//    }
    
//    public static func == (lhs: MapTrackPoint, rhs: MapTrackPoint) -> Bool {
//
//        var isEqual = false
//        if let lhsLocation = lhs.location?.coordinate, let rhsLocation = rhs.location?.coordinate {
//            isEqual = (lhsLocation == rhsLocation)
//        }
//        isEqual = isEqual && (lhs.userField == rhs.userField) && (lhs.timestamp == rhs.timestamp)
//        return isEqual
//    }

}

public class MapPath: NSObject {
    
    public var mapTrackPoints: [MapTrackPoint] = []
    
    public var userTraversedPathOverlays: [MapTrackingPolyline] = []
    
    public var userCurrentPositionPoint: MapTrackPoint?

    public var userIdentifier: String? {
        return mapTrackPoints.first?.userField
    }
    
    public var color: UIColor?
    public var userPathColor: UIColor?

    //MARK: Annotations
    fileprivate var pointAnnotation: UserPointAnnotation?
//    fileprivate var pinAnnotationView: MapTrackingAnnotationView?

    //MARK:
    init(mapTracks: [MapTrackPoint]) {
        self.mapTrackPoints = mapTracks
        self.userCurrentPositionPoint = mapTrackPoints.first
    }
    
//    func getPinAnnotation() -> MapTrackingAnnotationView? {
//        
//        if pointAnnotation == nil {
//            pointAnnotation = UserPointAnnotation()
//            pointAnnotation?.identifier = mapTrackPoints.first?.userField ?? ""
//            pointAnnotation?.imageIconUrl = mapTrackPoints.first?.imageIconUrl
//            pinAnnotationView = MapTrackingAnnotationView(annotation: pointAnnotation, reuseIdentifier: CellIdetifiers.pinCellId)
//        }
//        return pinAnnotationView
//    }

}

extension MapPath {
    struct CellIdetifiers {
        static let pinCellId = "pinCellId"
    }
}


public class UserPointAnnotation: MKPointAnnotation {
    public var identifier: String          =   ""
    public var color: UIColor              = .red //CurrentTheme.darkBackgroundColor
    public var mapTrack: MapTrackPoint?
    public var imageIconUrl: String?
}


