//
//  CustomPanels.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public class MetricPanel: Panel {
 
    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class TilePanel: Panel {
    
    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class SavedSearchPanel: Panel {
    
    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

}


public class HeatMapPanel: Panel {
    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

}


public class MapTrackingPanel: Panel {
    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class FaceTilePanel: Panel {
    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

}

public class GraphPanel: Panel {
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
    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}
