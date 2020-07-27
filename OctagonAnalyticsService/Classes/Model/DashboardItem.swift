//
//  DashboardItem.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 20/07/2020.
//

import Foundation
import Alamofire

//MARK: Public
public class DashboardItem {
    
    public var title: String
    public var id: String
    public var type: String
    public var desc: String
    public var panels: [Panel]  =   []
    public var fromTime: String
    public var toTime: String
    
    var panelsJsonList: [[String: Any]] =   []

    init(_ responseModel: DashboardItemResponseBase) {
        self.title      =   responseModel.attributes.title
        self.id         =   responseModel.id
        self.type       =   responseModel.type
        self.desc       =   responseModel.attributes.desc
        self.panels     =   responseModel.attributes.panels.compactMap({ $0.asUIModel() })
        self.fromTime   =   responseModel.attributes.timeFrom
        self.toTime     =   responseModel.attributes.timeTo
    }
}

//MARK: Private
class DashboardItemResponseBase: Decodable {
    var id: String
    var type: String
    var attributes: DashboardAttributesResponseBase

    private enum CodingKeys: String, CodingKey {
        case id         =   "id"
        case type       =   "type"
        case attributes =   "attributes"
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)

        self.id         = try container.decode(String.self, forKey: .id)
        self.type       = try container.decode(String.self, forKey: .type)
        self.attributes = try container.decode(DashboardAttributesResponseBase.self, forKey: .attributes)
        
        self.attributes.panels.forEach({ $0.dashboardItemBase = self })
    }

    func asUIModel() -> DashboardItem {
        return DashboardItem(self)
    }
}

class DashboardAttributesResponseBase: Decodable, ParseJsonArrayProtocol {
    var title: String
    var timeFrom: String
    var timeTo: String
    var desc: String
    var panels: [PanelBase] =   []
    
    var panelsJsonList: [[String: Any]] =   []
    
    private enum CodingKeys: String, CodingKey {
        case title      =   "title"
        case timeFrom   =   "timeFrom"
        case timeTo     =   "timeTo"
        case desc       =   "description"
        case panels     =   "panelsJSON"
    }
    
    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)

        self.title      = try container.decode(String.self, forKey: .title)
        self.desc       = try container.decode(String.self, forKey: .desc)
        self.timeFrom   = try container.decode(String.self, forKey: .timeFrom)
        self.timeTo     = try container.decode(String.self, forKey: .timeTo)
        
        let json = try container.decode(String.self, forKey: .panels)
        if let data = json.data(using: .utf8),
            let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [[String: Any]] {
            self.panelsJsonList = jsonArray
        }
    }
}

//MARK: Version 7.3.2
class DashboardItemResponse732: DashboardItemResponseBase {
    var references: [References] = []
    
    private enum CodingKeys: String, CodingKey {
        case panelRefName    =   "references"
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.references = try container.decode([References].self, forKey: .panelRefName)
        try super.init(from: decoder)
    }

}

class References: Decodable {
    var name: String
    var type: String
    var id: String
    
    private enum CodingKeys: String, CodingKey {
        case name, type, id
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(String.self, forKey: .type)
        self.id = try container.decode(String.self, forKey: .id)
    }

}
