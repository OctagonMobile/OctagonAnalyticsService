//
//  IPFieldResponse.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 29/07/2020.
//

import Foundation

public class IPFieldService {
    public var name: String            =   ""
    public var type: String            =   ""
    public var count: Int
    public var scripted: Bool          =   false
    public var searchable: Bool        =   false
    public var aggregatable: Bool      =   false
    public var readFromDocValues: Bool =   false

    init(_ responseModel: IPFieldResponseBase) {
        self.name           =   responseModel.name
        self.type           =   responseModel.type
        self.count          =   responseModel.count
        self.scripted       =   responseModel.scripted
        self.searchable     =   responseModel.searchable
        self.aggregatable   =   responseModel.aggregatable
        self.readFromDocValues   =   responseModel.readFromDocValues
    }
}

//MARK: Private
class IPFieldResponseBase: Decodable {
    
    var name: String            =   ""
    var type: String            =   ""
    var count: Int
    var scripted: Bool          =   false
    var searchable: Bool        =   false
    var aggregatable: Bool      =   false
    var readFromDocValues: Bool =   false

    private enum CodingKeys: String, CodingKey {
        case name, type, count, scripted, searchable, aggregatable, readFromDocValues
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        name                =   try container.decode(String.self, forKey: .name)
        type                =   try container.decode(String.self, forKey: .type)
        count               =   try container.decode(Int.self, forKey: .count)
        scripted            =   try container.decode(Bool.self, forKey: .scripted)
        searchable          =   try container.decode(Bool.self, forKey: .searchable)
        aggregatable        =   try container.decode(Bool.self, forKey: .aggregatable)
        readFromDocValues   =   try container.decode(Bool.self, forKey: .readFromDocValues)

    }
    
    func asUIModel() -> IPFieldService {
        return IPFieldService(self)
    }
}
