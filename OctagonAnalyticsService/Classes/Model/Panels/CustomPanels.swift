//
//  CustomPanels.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public class MetricPanelService: PanelService {
 
    public var metricsList: [MetricService] = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class TilePanelService: PanelService {
    
    public var tileList: [TileService] = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class SavedSearchPanelService: PanelService {
    
    public var totalSavedSearchCount: Int      = 0
    
    public var columns: [String]               = []

    public var hits: [SavedSearchService]             = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

    public func loadSavedSearch(_ pageNumber: Int, _ completion: CompletionBlock?) {
    }
}

public class HeatMapPanelService: PanelService {
    
    public var mapDetail: [MapDetailsService] = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

}

public class MapTrackingPanelService: PanelService {
    
    public var pathTrackersArray: [MapPath] = []
    
    /// List of Top "numberOfItemsToShowOnMap(50)" items based on number of locations in descending order
    public var sortedTracks: [MapTrackPointService]            = []
    
    /// Is map real time.
    public var isRealTime: Bool                    = false
    
    private var tracks: [MapTrackPointService]          = []
    private let numberOfItemsToShowOnMap    = 20

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}

public class FaceTilePanelService: PanelService {
    
    public var filterName: String?
    
    public var faceTileList: [FaceTileService] = []

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }

}

public class GraphPanelService: PanelService {
    
    public var graphData: NeoGraphService?

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
    
    public func loadGraphData(_ completion: CompletionBlock?) {
        
//        let urlComponent = UrlComponents.graphUrlComponent
//
//        var params = dataParams()
//        params?["query"] = (visState as? GraphVisState)?.query
//
//        DataManager.shared.loadData(urlComponent, methodType: .post, encoding: JSONEncoding.default, parameters: params) { [weak self] (result, error) in
//
//            guard error == nil else {
//                self?.resetDataSource()
//                completion?(nil, error)
//                return
//            }
//
//            guard let res = result as? [AnyHashable: Any?], let finalResult = res["result"], let parsedData = self?.parseGraphData(finalResult) else {
//                self?.resetDataSource()
//                let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: SomethingWentWrong])
//                completion?(nil, error)
//                return
//            }
//            completion?(parsedData, error)
//        }
    }
    
//    fileprivate func parseGraphData(_ result: Any?) -> NeoGraph? {
//        guard let responseJson = result as? [String: Any], visState?.type != .unKnown,
//            let remappedDict = responseJson["remapped"] as? [String: Any], let mappedData = remappedDict["data"] as? [String: Any],
//            let data = (mappedData["results"] as? [[String: Any]])?.first else {
//                return nil
//        }
//
//        graphData = NeoGraph(JSON: data)
//        return graphData
//    }
    
    override func resetDataSource() {
        super.resetDataSource()
        graphData = nil
    }

}

public class GaugePanelService: PanelService {
    
    public var gaugeValue: CGFloat =   0.0

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}


public class ControlsPanelService: PanelService {
    
    public var maxAgg: CGFloat?
    
    public var minAgg: CGFloat?

    override init(_ responseModel: PanelBase) {
        super.init(responseModel)
    }
}
