//
//  CustomVisState.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public class WebContentVisState: VisState {
    
    public var htmlString: String      = ""
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        
        self.htmlString =   responseModel.params.html ?? ""
    }
}

public class TagCloudVisState: VisState {
    
    var minFontSize: NSInteger    = 14
    
    var maxFontSize: NSInteger    = 60
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        
        self.minFontSize =   responseModel.params.minFontSize ?? 14
        self.maxFontSize =   responseModel.params.maxFontSize ?? 60
    }
}

public class MarkDownVisState: VisState {
    
    var markdownText: String    =   ""
    var fontSize: CGFloat       =   12.0
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.markdownText   =   responseModel.params.markdownText ?? ""
        self.fontSize       =   responseModel.params.fontSize ?? 12.0
    }
}

public class PieChartVisState: VisState {
    
    var isDonut: Bool   = false
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.isDonut    =   responseModel.params.isDonut ?? false
    }
}

public class TileVisState: VisState {
    
    var imageHashField: String      = ""
    var maxDistance: Int            = 15
    var containerId: Int            = 1
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.imageHashField =   responseModel.params.imageHashField ?? ""
        self.maxDistance    =   responseModel.params.maxDistance ?? 15
        self.containerId    =   responseModel.params.containerId ?? 1
    }
}

public class GraphVisState: VisState {
    
    var query: String               =   ""
    var nodeImageBaseUrl: String    =   ""
    var nodeImageProperty: String   =   ""
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.query              =   responseModel.params.query ?? ""
        self.nodeImageBaseUrl   =   responseModel.params.nodeImageBaseUrl ?? ""
        self.nodeImageProperty  =   responseModel.params.nodeImageProperty ?? ""
    }
}

public class MetricVisState: VisState {
    
    var fontSize: CGFloat?            = 10.0
    

}
