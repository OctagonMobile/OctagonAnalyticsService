//
//  IndexPatternsListResponseBase.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 29/07/2020.
//

import Foundation

public class IndexPatternsListResponse {
    public var page: Int
    public var pageSize: Int
    public var total: Int
    public var indexPatterns: [IndexPatternService] = []
    
    init(_ responseModel: IndexPatternsListResponseBase) {
        self.page       =   responseModel.page
        self.pageSize   =   responseModel.pageSize
        self.total      =   responseModel.total
        self.indexPatterns  =   responseModel.indexPatterns.compactMap({ $0.asUIModel() })
    }
}

//MARK: Private
class IndexPatternsListResponseBase: Decodable, ParseJsonArrayProtocol {
    
    var page: Int
    var pageSize: Int
    var total: Int
    var indexPatterns: [IndexPatternResponseBase] = []

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
            self.indexPatterns = try parse(jsonArray, type: ServiceConfiguration.version.indexPatternResponseModel.self)
        }
    }

    func asUIModel() -> IndexPatternsListResponse {
        return IndexPatternsListResponse(self)
    }
}
