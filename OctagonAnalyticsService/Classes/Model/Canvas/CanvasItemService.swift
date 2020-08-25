//
//  CanvasItemService.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 25/08/2020.
//

import Foundation

public class CanvasItemService {
    
    public var name: String
    public var id: String
    public var type: String

    init(_ responseModel: CanvasItemResponseBase) {
        self.name   =   responseModel.attributes.name
        self.id     =   responseModel.id
        self.type   =   responseModel.type
    }
}

//MARK: Private
class CanvasItemResponseBase: Decodable {
    
    var id: String
    var type: String
    var attributes: CanvasAttributesResponseBase

    private enum CodingKeys: String, CodingKey {
        case id, type, attributes
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id         = try container.decode(String.self, forKey: .id)
        self.type       = try container.decode(String.self, forKey: .type)
        self.attributes = try container.decode(CanvasAttributesResponseBase.self, forKey: .attributes)
    }
    
    func asUIModel() -> CanvasItemService {
        return CanvasItemService(self)
    }
}

class CanvasAttributesResponseBase: Decodable, ParseJsonArrayProtocol {
    
    var name: String
    var width: Int
    var height: Int
    var page: Int
    var pages: [CanvasPages]

    private enum CodingKeys: String, CodingKey {
        case name, width, height, page, pages
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name       =   try container.decode(String.self, forKey: .name)
        self.width      =   try container.decode(Int.self, forKey: .width)
        self.height     =   try container.decode(Int.self, forKey: .height)
        self.page       =   try container.decode(Int.self, forKey: .page)
        self.pages      =   try container.decode([CanvasPages].self, forKey: .pages)

    }
}

class CanvasPages: Decodable {
    
    var id: String
    
    private enum CodingKeys: String, CodingKey {
        case id
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id       =   try container.decode(String.self, forKey: .id)
    }
}
