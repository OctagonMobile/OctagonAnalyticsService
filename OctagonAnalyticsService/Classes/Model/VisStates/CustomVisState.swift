//
//  CustomVisState.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/07/2020.
//

import Foundation

public class WebContentVisStateService: VisStateService {
    
    public var htmlString: String      = ""
    
    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        
        guard let visstateBaseModel = responseModel.visStateBase else { return }
        self.htmlString =   visstateBaseModel.params?.html ?? ""
    }
}

public class TagCloudVisStateService: VisStateService {
    
    public var minFontSize: NSInteger    = 14
    
    public var maxFontSize: NSInteger    = 60
    
    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        
        guard let visstateBaseModel = responseModel.visStateBase else { return }
        self.minFontSize =   visstateBaseModel.params?.minFontSize ?? 14
        self.maxFontSize =   visstateBaseModel.params?.maxFontSize ?? 60
    }
}

public class MarkDownVisStateService: VisStateService {
    
    public var markdownText: String    =   ""
    public var fontSize: CGFloat       =   12.0
    
    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        guard let visstateBaseModel = responseModel.visStateBase else { return }
        self.markdownText   =   visstateBaseModel.params?.markdownText ?? ""
        self.fontSize       =   visstateBaseModel.params?.fontSize ?? 12.0
    }
}

public class PieChartVisStateService: VisStateService {
    
    public var isDonut: Bool   = false
    
    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        guard let visstateBaseModel = responseModel.visStateBase else { return }
        self.isDonut    =   visstateBaseModel.params?.isDonut ?? false
    }
}

public class TileVisStateService: VisStateService {
    
    public var imageHashField: String      = ""
    public var maxDistance: Int            = 15
    public var containerId: Int            = 1
    public var specifytype: TileType        = .unknown
    public var imlServer: String            = ""
    public var urlThumbnail: String         = ""
    public var images: String               = ""
    public var thumbnailFilePath: String?
    public var imageFilePath: String?

    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        guard let visstateBaseModel = responseModel.visStateBase else { return }
        self.imageHashField =   visstateBaseModel.params?.imageHashField ?? ""
        self.maxDistance    =   visstateBaseModel.params?.maxDistance ?? 15
        self.containerId    =   visstateBaseModel.params?.containerId ?? 1
        self.specifytype    =   visstateBaseModel.params?.specifytype ?? .unknown
        self.imlServer      =   visstateBaseModel.params?.imlServer ?? ""
        self.urlThumbnail   =   visstateBaseModel.params?.urlThumbnail ?? ""
        self.images         =   visstateBaseModel.params?.images ?? ""
        self.thumbnailFilePath  =   visstateBaseModel.params?.thumbnailFilePath
        self.imageFilePath  =   visstateBaseModel.params?.imageFilePath
    }
}

public class GraphVisStateService: VisStateService {
    
    public var query: String               =   ""
    public var nodeImageBaseUrl: String    =   ""
    public var nodeImageProperty: String   =   ""
    
    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        guard let visstateBaseModel = responseModel.visStateBase else { return }
        self.query              =   visstateBaseModel.params?.query ?? ""
        self.nodeImageBaseUrl   =   visstateBaseModel.params?.nodeImageBaseUrl ?? ""
        self.nodeImageProperty  =   visstateBaseModel.params?.nodeImageProperty ?? ""
    }
}

public class MetricVisStateService: VisStateService {
    
    public var fontSize: CGFloat?            = 10.0
    
    override init(_ responseModel: VisStateHolderBase) {
        super.init(responseModel)
        
        guard let visstateBaseModel = responseModel.visStateBase else { return }
        self.fontSize   =   visstateBaseModel.params?.metric?.fontSize ?? 10.0
    }
}
