//
//  FaceTileVizDataParams.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 10/09/2020.
//

import Foundation

public class FaceTileVizDataParams: VizDataParams {
    
    public var file: String     =   ""
    public var faceUrl: String  =   ""
    public var box: String      =   ""
    
    override var size: Int {
        return 1000
    }
    
    //MARK: Functions

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
            
            let fieldsArray = (hitContent["fields"] as? [String])

            //Face - URL
            guard let currentTypeFilename = getFieldName(fieldsArray, path: file, sourceDict: sourceDict) else { continue }
            let face_url = generateUrlWith(faceUrl, path: currentTypeFilename)

            let obsoleteESResponse = (box == "processed.faces.box")
            
            var faces: [String] = []
            if obsoleteESResponse {
                let facesPath = ["processed", "faces"]
                
                var facesList: [[String: Any]] = []
                var tempDict: [String: Any]? = sourceDict
                for (index, pathKey) in facesPath.enumerated() {
                    guard index != facesPath.count - 1 else {
                        facesList = tempDict?[pathKey] as? [[String: Any]] ?? []
                        break
                    }
                    tempDict = tempDict?[pathKey] as? [String: Any]
                }
                
                for faceContent in facesList {
                    if let box = faceContent["box"] as? String, face_url.contains("{{box}}") {
                        faces.append(face_url.replacingOccurrences(of: "{{box}}", with: box))
                    }
                }
                
                if faces.count > 1 {
                    dict["faces"] = faces
                    dict["fileName"] = currentTypeFilename
                    tilesList.append(dict)
                }
                
            } else {
                var facesUrl = face_url

                var currentBox: String?
                var tempDict: [String: Any]? = sourceDict
                let facesPath = box.components(separatedBy: ".")
                for (index, pathKey) in facesPath.enumerated() {
                    guard index != facesPath.count - 1 else {
                        currentBox = tempDict?[pathKey] as? String
                        break
                    }
                    tempDict = tempDict?[pathKey] as? [String: Any]
                }

                if let currentBox = currentBox, face_url.contains("{{box}}") {
                    facesUrl = face_url.replacingOccurrences(of: "{{box}}", with: currentBox)
                }

                dict["faces"] = [facesUrl]
                dict["fileName"] = currentTypeFilename
                tilesList.append(dict)
            }
        }
        
        responseContent?["hits"] = ["hits": tilesList]
        return ["responses": [responseContent]]
    }
}
