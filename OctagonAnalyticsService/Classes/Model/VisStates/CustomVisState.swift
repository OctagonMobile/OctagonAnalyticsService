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
    
    public var minFontSize: NSInteger    = 14
    
    public var maxFontSize: NSInteger    = 60
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        
        self.minFontSize =   responseModel.params.minFontSize ?? 14
        self.maxFontSize =   responseModel.params.maxFontSize ?? 60
    }
}

public class MarkDownVisState: VisState {
    
    public var markdownText: String    =   ""
    public var fontSize: CGFloat       =   12.0
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.markdownText   =   responseModel.params.markdownText ?? ""
        self.fontSize       =   responseModel.params.fontSize ?? 12.0
    }
}

public class PieChartVisState: VisState {
    
    public var isDonut: Bool   = false
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.isDonut    =   responseModel.params.isDonut ?? false
    }
}

public class TileVisState: VisState {
    
    public var imageHashField: String      = ""
    public var maxDistance: Int            = 15
    public var containerId: Int            = 1
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.imageHashField =   responseModel.params.imageHashField ?? ""
        self.maxDistance    =   responseModel.params.maxDistance ?? 15
        self.containerId    =   responseModel.params.containerId ?? 1
    }
}

public class GraphVisState: VisState {
    
    public var query: String               =   ""
    public var nodeImageBaseUrl: String    =   ""
    public var nodeImageProperty: String   =   ""
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        self.query              =   responseModel.params.query ?? ""
        self.nodeImageBaseUrl   =   responseModel.params.nodeImageBaseUrl ?? ""
        self.nodeImageProperty  =   responseModel.params.nodeImageProperty ?? ""
    }
}

public class MetricVisState: VisState {
    
    public var fontSize: CGFloat?            = 10.0
    
    override init(_ responseModel: VisStateBase) {
        super.init(responseModel)
        
        self.fontSize   =   responseModel.params.fontSize ?? 10.0
    }
}
