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
    case loadVideoData(indexPatternName: String, query: [String: Any])
    case loadVideoDataTotalCount(indexPatternName: String, query: [String: Any])

    var serverPath: ServerPaths {
        switch self {
        case .loadIndexPatterns:
            return ServerPaths.indexPatternList
        case .loadVideoData, .loadVideoDataTotalCount:
            return ServerPaths.videoData
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .loadIndexPatterns(pageNumber: let pageNo, pageSize: let pageSize):
            return ["type": "index-pattern", "page": pageNo, "per_page": pageSize]
        case .loadVideoData(indexPatternName: let name, query: _):
            return ["path": (name + "/_search"), "method": "POST"]
        case .loadVideoDataTotalCount(indexPatternName: let name, query: _):
            return ["path": (name + "/_search?track_total_hits=true"), "method": "POST"]
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .loadIndexPatterns:
            return URLEncoding.default
        case .loadVideoData, .loadVideoDataTotalCount:
            return URLEncoding.queryString
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
    
    var headers: HTTPHeaders {
        var header = defHeaders

        switch self {
        case .loadVideoData, .loadVideoDataTotalCount:
            header["Content-Type"]  =   "application/json"
        default: break
        }
        return header
    }
    
    var httpBodyContent: Data? {
        switch self {
        case .loadVideoData(indexPatternName: _, query: let queryJson):
            return try? JSONSerialization.data(withJSONObject: queryJson, options: .prettyPrinted)
        case .loadVideoDataTotalCount(indexPatternName: _, query: let queryJson):
            return try? JSONSerialization.data(withJSONObject: queryJson, options: .prettyPrinted)
        default:
            return nil
        }

    }

}
