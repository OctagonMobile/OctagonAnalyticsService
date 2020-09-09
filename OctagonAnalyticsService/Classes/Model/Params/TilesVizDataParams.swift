//
//  TilesVizDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 26/08/2020.
//

import Foundation

public class TilesVizDataParams: VizDataParams {
    
    public var specifyType: TileType
    public var urlThumbnail: String     =   ""
    public var thumbnailFilePath: String = ""
    public var imlServer: String        = ""
    public var imageFilePath: String    = ""
    public var imageHashField: String   =   ""

    override var size: Int {
        return 1000
    }
    //MARK: Functions
    public init(_ indexPatternId: String, tileViewType: TileType) {
        self.specifyType = tileViewType
        super.init(indexPatternId)
    }

    override func postResponseProcedure(_ response: Any) -> Any? {
        let error = parseResponseForError(response as? [String: Any])
        guard error == nil else {
            return error
        }

        guard let result = response as? [String: Any] else { return response }
        var responseContent = (result["responses"] as? [[String: Any]])?.first

        guard let hits = (responseContent?["hits"] as? [String: Any])?["hits"] as? [[String:Any]] else { return response }
        
        //Used to get the field name from response
        func getFieldName(_ fieldsArray: [String]?, path: String, sourceDict: [String: Any]?) -> String? {
            var fieldName: String?
            if let filteredFieldsList = fieldsArray?.filter({ $0 == path}), filteredFieldsList.count > 0 {
                fieldName = filteredFieldsList.first
            } else {
                let filePathContent = path.components(separatedBy: ".")
                
                var tempDict: [String: Any]? = sourceDict
                for (index, pathKey) in filePathContent.enumerated() {
                    guard index != filePathContent.count - 1 else {
                        fieldName = tempDict?[pathKey] as? String
                        break
                    }
                    tempDict = tempDict?[pathKey] as? [String: Any]
                }
            }
            return fieldName
        }
        
        // Used to generate complete url
        func generateUrlWith(_ base: String, path: String?) -> String {
            if base.contains("{{file}}") {
                if let path = path {
                    return base.replacingOccurrences(of: "{{file}}", with: path)
                }
            } else {
                return base + (path ?? "")
            }
            return base
        }

        var tilesList: [[String: Any]] = []
        for hitContent in hits {

            var dict: [String: Any] = [:]
            
            let sourceDict = hitContent["_source"] as? [String: Any]
            
            dict["type"] = specifyType.rawValue
            dict["timestamp"] = sourceDict?["@timestamp"]
            
            let fieldsArray = (hitContent["fields"] as? [String])
                        
            //Thumbnail - URL
            let thumbnailFileName = getFieldName(fieldsArray, path: thumbnailFilePath, sourceDict: sourceDict)
            dict["thumbnailUrl"] = generateUrlWith(urlThumbnail, path: thumbnailFileName)

            //Content - URL
            let currentTypeFilename = getFieldName(fieldsArray, path: imageFilePath, sourceDict: sourceDict)
            let urlPath = generateUrlWith(imlServer, path: currentTypeFilename)
            
            switch specifyType {
            case .photo:
                dict["imageUrl"] = urlPath
            case .video:
                dict["videoUrl"] = urlPath
            case .audio:
                dict["audioUrl"] = urlPath
            default:
                break
            }
            
            //ImageHash
            dict["imageHash"] = getFieldName(fieldsArray, path: imageHashField, sourceDict: sourceDict)

            tilesList.append(dict)
        }
        
        responseContent?["hits"] = ["hits": tilesList]
        return ["responses": [responseContent]]
    }
}
