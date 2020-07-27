//
//  CustomPanels.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public class MetricPanel: Panel {
 
    public var metricsList: [Metric] = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class TilePanel: Panel {
    
    public var tileList: [Tile] = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class SavedSearchPanel: Panel {
    
    public var totalSavedSearchCount: Int      = 0
    
    public var columns: [String]               = []

    public var hits: [SavedSearch]             = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

}

public class HeatMapPanel: Panel {
    
    public var mapDetail: [MapDetails] = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

}

public class MapTrackingPanel: Panel {
    
    public var pathTrackersArray: [MapPath] = []
    
    /// List of Top "numberOfItemsToShowOnMap(50)" items based on number of locations in descending order
    public var sortedTracks: [MapTrackPoint]            = []
    
    /// Is map real time.
    public var isRealTime: Bool                    = false
    
    private var tracks: [MapTrackPoint]          = []
    private let numberOfItemsToShowOnMap    = 20

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class FaceTilePanel: Panel {
    
    public var filterName: String?
    
    public var faceTileList: [FaceTile] = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

}

public class GraphPanel: Panel {
    
    public var graphData: NeoGraph?

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class GaugePanel: Panel {
    
    public var gaugeValue: CGFloat =   0.0

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}


public class ControlsPanel: Panel {
    
    public var maxAgg: CGFloat?
    
    public var minAgg: CGFloat?

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}
