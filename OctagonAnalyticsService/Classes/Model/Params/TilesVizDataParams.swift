//
//  TilesVizDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/08/2020.
//

import Foundation

public class TilesVizDataParams: VizDataParamsBase {
    
    public var specifyType: TileType
    public var images: String?
    public var audio: String?
    public var video: String?
    
    public enum TileType: String {
        case images = "images"
        case video = "video"
        case audio = "audio"
        
        var urlName: String {
            switch self {
            case .images:
                return "imageUrl"
            case .video:
                return "videoUrl"
            case .audio:
                return "audioUrl"
            }
        }
    }
    
    public init(_ tileViewType: TileType) {
        self.specifyType = tileViewType        
        super.init("")
    }

    //MARK:
    override func postResponseProcedure(_ response: Any) -> Any? {
        let content = super.postResponseProcedure(response)
        guard !(content is OAServiceError) else {
            return content
        }

        guard let result = response as? [String: Any] else { return response }
        let responseContent = (result["responses"] as? [[String: Any]])?.first

        guard let hits = (responseContent?["hits"] as? [String: Any])?["hits"] as? [[String:Any]] else { return response }
        
        var tilesList: [[String: Any]] = []
        for hitContent in hits {
            
            let paramsContent = hitContent["params"] as? [String: Any]
            
            var dict: [String: Any] = [:]
            dict["sddd"] = paramsContent?[specifyType.urlName] as? String
            tilesList.append(dict)
        }
        
        return response
    }
}
