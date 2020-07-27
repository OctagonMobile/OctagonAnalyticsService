//
//  MapTrackingPolyline.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation
import MapKit

public class MapTrackingPolyline: MKPolyline {
    public var color: UIColor = .red //CurrentTheme.darkBackgroundColor
    public var userPathColor: UIColor = .red//CurrentTheme.darkBackgroundColor
    public var isUserPath: Bool = false
}

public class MapTrackingCircle: MKCircle {
    public var isFirstCircle: Bool = false
    public var isLastCircle: Bool = false
    public var color: UIColor = .red //CurrentTheme.darkBackgroundColor

    //MARK: Read Only Properties
    public var fillColor: UIColor {
        if isFirstCircle { return color }
        else if isLastCircle { return UIColor.white }
        else { return .red }//CurrentTheme.darkBackgroundColor }
    }
    
    public var strokeColor: UIColor? {
        if isFirstCircle { return UIColor.white }
        else if isLastCircle { return color }
        else { return nil }
    }
    
    public var fillAlpha: CGFloat {
        return (isFirstCircle || isLastCircle) ? 1.0 : 0.8
    }

    public var strokeLineWidth: CGFloat {
        return (isFirstCircle || isLastCircle) ? 3.0 : 0.0
    }
}
