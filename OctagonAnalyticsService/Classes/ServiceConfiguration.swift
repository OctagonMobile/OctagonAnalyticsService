//
//  ServiceConfiguration.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 19/07/2020.
//

import Foundation

public struct ServiceConfiguration {

    static var baseUrl: String         =   ""
    static var version: VersionType    =   .v654
    
    // Timeout for query in milli seconds
    static var timeout: Int             =   3000

    public static func configure(_ baseUrl: String, version: VersionType = .v654)  {
        ServiceConfiguration.baseUrl = baseUrl
        ServiceConfiguration.version = version
    }
}

public enum VersionType: String {
    case v654   =   "Version 6.5.4"
    case v732   =   "Version 7.3.2"
    
    var loginResponseModel: LoginResponseBase.Type {
        switch self {
        case .v654: return LoginResponseBase.self
        case .v732: return LoginResponse732.self
        }
    }
    
    var dashboardListModel: DashboardListReponseBase.Type {
        switch self {
        case .v654, .v732: return DashboardListReponseBase.self
        }
    }
    
    var dashboardItemResponseModel: DashboardItemResponseBase.Type {
        switch self {
        case .v654: return DashboardItemResponse654.self
        case .v732: return DashboardItemResponse732.self
        }
    }

    var panelModel: PanelBase.Type {
        switch self {
        case .v654: return Panel654.self
        case .v732: return Panel732.self
        }
    }
    
    var visStateModel: VisStateHolderBase.Type {
        switch self {
        case .v654: return VisStateHolderBase654.self
        case .v732: return VisStateHolderBase732.self
        }
    }
    
    var indexPatternListModel: IndexPatternsListResponseBase.Type {
        switch self {
        case .v654, .v732: return IndexPatternsListResponseBase.self
        }
    }

    var indexPatternResponseModel: IndexPatternResponseBase.Type {
        switch self {
        case .v654, .v732: return IndexPatternResponseBase.self
        }
    }

    var ipFieldResponseModel: IPFieldResponseBase.Type {
        switch self {
        case .v654: return IPFieldResponseBase654.self
        case .v732: return IPFieldResponseBase732.self
        }
    }

    var canvasListModel: CanvasListReponseBase.Type {
        switch self {
        case .v654, .v732: return CanvasListReponseBase.self
        }
    }

    var canvasItemResponseModel: CanvasItemResponseBase.Type {
        switch self {
        case .v654: return CanvasItemResponseBase.self
        case .v732: return CanvasItemResponseBase.self
        }
    }

    var vizDataQueryParams: [String: String]? {
        switch self {
        case .v654: return nil
        case .v732: return ["rest_total_hits_as_int": "true"]
        }
    }
    
    func getTotalFrom(_ result: [String: Any]?) -> CGFloat? {
        switch self {
        case .v654:
            return result?["total"] as? CGFloat
        case .v732:
            return (result?["total"] as? [String: Any])?["value"] as? CGFloat
        }
    }
}
