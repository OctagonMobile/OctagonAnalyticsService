//
//  CanvasServiceBuilder.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 25/08/2020.
//

import Foundation
import Alamofire

enum CanvasServiceBuilder: URLRequestBuilder {
    
    case loadCanvasList(pageNumber: Int, pageSize: Int)

    var serverPath: ServerPaths {
        switch self {
        case .loadCanvasList:
            return ServerPaths.canvasList
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .loadCanvasList(pageNumber: let pageNo, pageSize: let pageSize):
            return ["type": "canvas-workpad", "page": pageNo, "per_page": pageSize]
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
}
