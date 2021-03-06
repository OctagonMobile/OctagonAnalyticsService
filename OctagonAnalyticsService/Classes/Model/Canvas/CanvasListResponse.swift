//
//  CanvasListResponse.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 25/08/2020.
//

import Foundation

public class CanvasListResponse {
    
    public var page: Int
    public var pageSize: Int
    public var total: Int
    public var canvasList: [CanvasItemService]

    init(_ responseModel: CanvasListReponseBase) {
        self.page       =   responseModel.page
        self.pageSize   =   responseModel.page
        self.total      =   responseModel.total
        self.canvasList =   responseModel.canvasList.compactMap({ $0.asUIModel() })
    }
}

//MARK: Private
class CanvasListReponseBase: Decodable, ParseJsonArrayProtocol {
    
    var page: Int
    var pageSize: Int
    var total: Int
    var canvasList: [CanvasItemResponseBase] = []

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
            self.canvasList = try parse(jsonArray, type: ServiceConfiguration.version.canvasItemResponseModel.self)
        }
    }

    func asUIModel() -> CanvasListResponse {
        return CanvasListResponse(self)
    }
}
