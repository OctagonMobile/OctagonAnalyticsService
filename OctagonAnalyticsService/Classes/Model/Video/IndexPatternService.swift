//
//  IndexPatternService.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 29/07/2020.
//

import Foundation

public class IndexPatternService {
    public var id: String              =   ""
    public var title: String           =   ""
    public var timeFieldName: String   =   ""
    public var fields: [IPFieldService] =   []
    
    init(_ responseModel: IndexPatternResponseBase) {
        self.id             =   responseModel.id
        self.title          =   responseModel.attributes.title
        self.timeFieldName  =   responseModel.attributes.timeFieldName ?? ""
        self.fields         =   responseModel.attributes.fields.compactMap({ $0.asUIModel() })
    }
}

//MARK: Private
class IndexPatternResponseBase: Decodable {
    
    var type: String        =   ""
    var id: String          =   ""
    var attributes: IndexPatternAttributesResponseBase
    
    private enum CodingKeys: String, CodingKey {
        case id, type, attributes
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        id              =  try container.decode(String.self, forKey: .id)
        type            =  try container.decode(String.self, forKey: .type)
        attributes      =  try container.decode(IndexPatternAttributesResponseBase.self, forKey: .attributes)
    }
    
    func asUIModel() -> IndexPatternService {
        return IndexPatternService(self)
    }
}

class IndexPatternAttributesResponseBase: Decodable, ParseJsonArrayProtocol {
    
    var title: String           =   ""
    var timeFieldName: String?
    var fields: [IPFieldResponseBase]   =   []

    private enum CodingKeys: String, CodingKey {
        case title, timeFieldName, fields
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        title           =   try container.decode(String.self, forKey: .title)
        timeFieldName   =   try? container.decode(String.self, forKey: .timeFieldName)
        
        let json = try container.decode(String.self, forKey: .fields)
        if let data = json.data(using: .utf8),
            let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [[String: Any]] {
            self.fields = try parse(jsonArray, type: ServiceConfiguration.version.ipFieldResponseModel.self)
        }

    }
}

