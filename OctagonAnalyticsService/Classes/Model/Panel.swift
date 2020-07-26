//
//  Panel.swift
//  Alamofire
//
//  Created by Rameez on 21/07/2020.
//

import Foundation
import Alamofire

//MARK: Public
public class Panel {
    
    var id: String?
    var panelIndex: String
    var row: Int
    var column: Int
    var width: Int
    var height: Int
    var visState: VisState?
    var searchQuery: String =   ""
    weak var dashboardItem: DashboardItem?
    var selectedDateString: String     =   ""
    
    var datePickerMode: DatePickerMode  =   .calendarPicker
    
    // YET to parse the following properties
    var displayDateString: String {
        return selectedDateString
//        return datePickerMode == .quickPicker ? (QuickPicker(rawValue: selectedDateString)?.localizedValue ?? selectedDateString) : selectedDateString
    }

    var chartContentList: [ChartContent] = []
    
    var parsedAgg: AggResult?
    
    var bucketType: BucketType {
        return visState?.aggregationsArray.filter( {$0.id == AggregationId.bucket.rawValue }).first?.bucketType ?? .unKnown
    }
    
    var bucketAggregation: Aggregation? {
        return visState?.aggregationsArray.filter( {$0.id == AggregationId.bucket.rawValue }).first
    }

    var tableHeaders: [String] = []

    init(_ responseModel: PanelBase) {
        self.panelIndex =   responseModel.panelIndex
        self.row        =   responseModel.gridData.x
        self.column     =   responseModel.gridData.y
        self.width      =   responseModel.gridData.w
        self.height     =   responseModel.gridData.h
//        self.dashboardItem = responseModel.dashboardItemBase?.asUIModel()
    }
    
    func updateVisStateFor(_ completion: CompletionBlock?) {
        
        let request = DashboardServiceBuilder.loadVisStateForId(panelId: id!)
        AF.request(request).responseData {[weak self] (response) in
            switch response.result {
            case .failure(let error):
                let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                completion?(nil, serviceError)
            case .success(let value):
                do {
                    let decoder = JSONDecoder()
                    let visStateModel = try decoder.decode(ServiceConfiguration.version.visStateModel.self, from: value)
                    self?.visState = visStateModel.asUIModel()
                    completion?(visStateModel, nil)
                } catch let error {
                    let serviceError = OAServiceError(description: error.localizedDescription, code: 1000)
                    completion?(nil, serviceError)
                }
            }
        }
    }

    public func loadChartData(_ completion: CompletionBlock?) {
        
        completion?(nil, nil)
    }
}

enum DatePickerMode: String {
    case quickPicker            =   "QuickPicker"
    case calendarPicker         =   "CalendarPicker"
}

public enum PanelType: String, Codable {
    case unKnown    =   "unKnown"
    case pieChart   =   "pie"
    case histogram  =   "histogram"
    case tagCloud   =   "tagcloud"
    case t4pTagcloud   =   "t4p-tagcloud"
    case table      =   "table"
    case search     =   "search"
    case metric     =   "metric"
    case tile       =   "t4p-tile"
    case heatMap    =   "tile_map"
    case mapTracking    =   "t4p-map"
    case vectorMap      =   "vectormap"
    case regionMap      =   "region_map"
    case faceTile       =   "t4p-face"
    case neo4jGraph     =   "t4p-neo4j-graph-graph"
    case html           =   "html"
    case line           =   "line"
    case horizontalBar  =   "horizontal_bar"
    case markdown       =   "markdown"
    case area           =   "area"
    case gauge          =   "gauge"
    case goal           =   "goal"
    case inputControls  =    "input_control_vis"
}

//MARK: Private
class PanelBase: Decodable {
    
    //ReadOnly
    weak var dashboardItemBase: DashboardItemResponseBase?
    
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
        
    var id: String
    private enum CodingKeys: String, CodingKey {
        case id    =   "id"
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        try super.init(from: decoder)
    }
    
    override func asUIModel() -> Panel {
        let panel = super.asUIModel()
        panel.id = id
        return panel
    }
}

//MARK: Version 7.3.2
class Panel732: PanelBase {
    var dashboardItemResponse: DashboardItemResponse732? {
        return dashboardItemBase as? DashboardItemResponse732
    }
    
    var panelRefName: String
    private enum CodingKeys: String, CodingKey {
        case panelRefName    =   "panelRefName"
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.panelRefName = try container.decode(String.self, forKey: .panelRefName)
        try super.init(from: decoder)
    }
    
    override func asUIModel() -> Panel {
        let panel = super.asUIModel()
        panel.id = dashboardItemResponse?.references.filter({$0.name == panelRefName}).first?.id
        return panel
    }
}
