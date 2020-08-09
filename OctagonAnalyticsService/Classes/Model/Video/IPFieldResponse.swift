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
    public var script: String?
    public var lang: String?

    init(_ responseModel: IPFieldResponseBase) {
        self.name           =   responseModel.name
        self.type           =   responseModel.type
        self.count          =   responseModel.count
        self.scripted       =   responseModel.scripted
        self.searchable     =   responseModel.searchable
        self.aggregatable   =   responseModel.aggregatable
        self.readFromDocValues   =   responseModel.readFromDocValues
        self.script         =   responseModel.script
        self.lang           =   responseModel.lang
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
    var script: String?
    var lang: String?

    private enum CodingKeys: String, CodingKey {
        case name, type, count, scripted, searchable, aggregatable, readFromDocValues, script, lang
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        name                =   try container.decode(String.self, forKey: .name)
        count               =   try container.decode(Int.self, forKey: .count)
        scripted            =   try container.decode(Bool.self, forKey: .scripted)
        searchable          =   try container.decode(Bool.self, forKey: .searchable)
        aggregatable        =   try container.decode(Bool.self, forKey: .aggregatable)
        script              =   try? container.decode(String.self, forKey: .script)
        lang                =   try? container.decode(String.self, forKey: .lang)
        
        if let typeValue =   try? container.decode(String.self, forKey: .type) {
            type    =   typeValue
        } else if let typeValue =   try? container.decode(Int.self, forKey: .type) {
            type    =   "\(typeValue)"
        }

    }
    
    func asUIModel() -> IPFieldService {
        return IPFieldService(self)
    }
}

//MARK: 6.5.4
class IPFieldResponseBase654: IPFieldResponseBase {
    
    private enum CodingKeys: String, CodingKey {
        case readFromDocValues
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        readFromDocValues   =   try container.decode(Bool.self, forKey: .readFromDocValues)
    }
}

//MARK: 7.3.2
class IPFieldResponseBase732: IPFieldResponseBase {
    
    var analyzed: Bool          =   false
    var docValues: Bool        =   false

    private enum CodingKeys: String, CodingKey {
        case analyzed, doc_values
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        analyzed    =   (try? container.decode(Bool.self, forKey: .analyzed)) ?? false
        docValues   =   (try? container.decode(Bool.self, forKey: .doc_values)) ?? false
    }

}
