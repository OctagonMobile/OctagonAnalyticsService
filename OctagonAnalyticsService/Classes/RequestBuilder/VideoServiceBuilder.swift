//
//  VideoServiceBuilder.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 29/07/2020.
//

import Foundation
import Alamofire

enum VideoServiceBuilder: URLRequestBuilder {
    
    case loadIndexPatterns(pageNumber: Int, pageSize: Int)
    case loadVideoData(path: String)

    var serverPath: ServerPaths {
        switch self {
        case .loadIndexPatterns:
            return ServerPaths.indexPatternList
        case .loadVideoData:
            return ServerPaths.videoData
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .loadIndexPatterns(pageNumber: let pageNo, pageSize: let pageSize):
            return ["type": "index-pattern", "page": pageNo, "per_page": pageSize]
        case .loadVideoData:
            return nil
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .loadIndexPatterns:
            return HTTPMethod.get
        default:
            return HTTPMethod.post
        }
    }

}
