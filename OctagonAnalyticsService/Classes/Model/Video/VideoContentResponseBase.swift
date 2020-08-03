//
//  VideoContentResponseBase.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 03/08/2020.
//

import Foundation

public class VideoContentListResponse {
    
    public var buckets: [VideoContentService]  =   []
    
    init(_ responseModel: VideoContentListResponseBase) {
        self.buckets    =   responseModel.videoDataAggregation?.bucketsList.compactMap({ $0.asUIModel() }) ?? []
    }
}

//MARK: Private
class VideoContentListResponseBase: Decodable {
    
    var videoDataAggregation: VideoDataAggregationResponse?
    
    private enum CodingKeys: String, CodingKey {
        case aggregations
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        videoDataAggregation = try container.decode(VideoDataAggregationResponse.self, forKey: .aggregations)
    }
    
    func asUIModel() -> VideoContentListResponse {
        return VideoContentListResponse(self)
    }
}
