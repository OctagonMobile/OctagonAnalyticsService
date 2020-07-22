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
        case .v654: return DashboardItemResponseBase.self
        case .v732: return DashboardItemResponse732.self
        }
    }

    var panelModel: PanelBase.Type {
        switch self {
        case .v654: return Panel654.self
        case .v732: return Panel732.self
        }
    }
}
