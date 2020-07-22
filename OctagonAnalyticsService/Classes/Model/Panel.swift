//
//  Panel.swift
//  Alamofire
//
//  Created by Rameez on 21/07/2020.
//

import Foundation

//MARK: Public
public class Panel {
    
    var id: String
    var panelIndex: String
    var row: Int
    var column: Int
    var width: Int
    var height: Int


    init(_ responseModel: PanelBase) {
        self.id         =   responseModel.panelId
        self.panelIndex =   responseModel.panelIndex
        self.row        =   responseModel.gridData.x
        self.column     =   responseModel.gridData.y
        self.width      =   responseModel.gridData.w
        self.height     =   responseModel.gridData.h
    }
}

//MARK: Private
class PanelBase: Decodable {
    
    //ReadOnly
    var panelId: String { return "" }
    
    var panelIndex: String
    var version: String
    var gridData: GridData
    
    private enum CodingKeys: String, CodingKey {
        case version    =   "version"
        case panelIndex =   "panelIndex"
        case gridData   =   "gridData"
    }
    
    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.panelIndex = try container.decode(String.self, forKey: .panelIndex)
        self.version    = try container.decode(String.self, forKey: .version)
        self.gridData   = try container.decode(GridData.self, forKey: .gridData)
    }
    
    func asUIModel() -> Panel {
        return Panel(self)
    }
}

class GridData: Decodable {
    var x: Int
    var y: Int
    var w: Int
    var h: Int
    var i: String
    
    private enum CodingKeys: String, CodingKey {
        case x, y, w, h, i
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.x  = try container.decode(Int.self, forKey: .x)
        self.y  = try container.decode(Int.self, forKey: .y)
        self.w  = try container.decode(Int.self, forKey: .w)
        self.h  = try container.decode(Int.self, forKey: .h)
        self.i  = try container.decode(String.self, forKey: .i)
    }

}

//MARK: Version 6.5.4
class Panel654: PanelBase {
    
    override var panelId: String {
        return id
    }
    var id: String
    private enum CodingKeys: String, CodingKey {
        case id    =   "id"
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        try super.init(from: decoder)
    }
}

//MARK: Version 7.3.2
class Panel732: PanelBase {
    
    var panelRefName: String
    private enum CodingKeys: String, CodingKey {
        case panelRefName    =   "panelRefName"
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.panelRefName = try container.decode(String.self, forKey: .panelRefName)
        try super.init(from: decoder)
    }
}

