//
//  DashboardListReponseBase.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 20/07/2020.
//

import Foundation

//MARK: Public
public class DashboardListResponse {
    
    public var page: Int
    public var pageSize: Int
    public var total: Int
    public var dashboards: [DashboardItem]

    init(_ responseModel: DashboardListReponseBase) {
        self.page       =   responseModel.page
        self.pageSize   =   responseModel.page
        self.total      =   responseModel.total
        self.dashboards =   responseModel.dashboards.compactMap({ $0.asUIModel() })
    }
}

//MARK: Private
class DashboardListReponseBase: Decodable, ParseJsonArrayProtocol {
    
    var page: Int
    var pageSize: Int
    var total: Int
    var dashboards: [DashboardItemResponseBase] = []

    private enum CodingKeys: String, CodingKey {
        case page       =   "page"
        case pageSize   =   "per_page"
        case total      =   "total"
        case savedObjects  =   "saved_objects"
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)

        self.page       = try container.decode(Int.self, forKey: .page)
        self.pageSize   = try container.decode(Int.self, forKey: .pageSize)
        self.total      = try container.decode(Int.self, forKey: .total)
        
        if let jsonArray: [[String: Any]] = try container.decode(Array<Any>.self, forKey: .savedObjects) as? [[String: Any]] {
            self.dashboards = try parse(jsonArray, type: ServiceConfiguration.version.dashboardItemResponseModel.self)
        }
    }

    func asUIModel() -> DashboardListResponse {
        return DashboardListResponse(self)
    }
}
