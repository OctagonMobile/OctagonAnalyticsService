//
//  Tile.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 27/07/2020.
//

import Foundation

public enum TileType: String {
    case unknown        = "unknown"
    case photo          = "Photo"
    case audio          = "Audio"
    case video          = "Video"
    
    public var name: String {
        switch self {
        case .photo: return "PHOTO"
        case .audio: return "AUDIO"
        case .video: return "VIDEO"
        default: return "Unknown"
        }
    }
    
}

public class Tile {
    
    public var type: TileType          = .unknown
    public var timestamp: Date?
    public var thumbnailUrl: String    = ""
    public var imageUrl: String        = ""
    public var videoUrl: String        = ""
    public var audioUrl: String        = ""
    public var imageHash: String = ""
    
    public var thumbnailImage: UIImage?

    public var timestampString: String? {
        guard let timestamp = timestamp else { return "" }
        return timestamp.toFormat("YYYY-MM-dd HH:mm:ss")
    }

    //MARK: Functions
    
//    func mapping(map: Map) {
//
//        type          <- (map[TileConstant.type],EnumTransform<TileType>())
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        if let dateString = map[TileConstant.timestamp].currentValue as? String, let _date = dateFormatter.date(from: dateString) {
//            timestamp = _date
//        }
//
//        thumbnailUrl            <- map[TileConstant.thumbnailUrl]
//        imageUrl                <- map[TileConstant.imageUrl]
//        videoUrl                <- map[TileConstant.videoUrl]
//        audioUrl                <- map[TileConstant.audioUrl]
//        imageHash               <- map[TileConstant.imageHash]
//    }
    
    public func loadImageHashesFor(_ panel: TilePanel, _ completion: @escaping CompletionBlock) {


        guard !imageHash.isEmpty else {
//            let error = NSError(domain: AppName, code: 101, userInfo: [NSLocalizedDescriptionKey: "Search image isn't available for the selected image.\n(Missing Image Hash)"])
//            completion(nil, error)
            return
        }

//        let search = "/search/" + imageHash
//        var containerId = "/container/"
//        var maxDistance = "/distance/"
//        if let visState = panel.visState as? TileVisState {
//            containerId += "\(visState.containerId)"
//            maxDistance += "\(visState.maxDistance)"
//        }

//        let url = Configuration.shared.imageHashBaseUrl + containerId + search + maxDistance
//        DataManager.shared.loadData(url: url, encoding: JSONEncoding.default, parameters: nil) { (result, error) in
//
//
//            guard error == nil else {
//                completion(nil, error)
//                return
//            }
//
//            guard let res = result as? [AnyHashable: Any?], let parsedDict = res[TileConstant.result] as? [String: Any], let hashesArray = parsedDict[TileConstant.hashes] as? [String] else {
//                completion(nil, error)
//                return
//            }
//
//            completion(hashesArray, nil)
//        }
    }
}
