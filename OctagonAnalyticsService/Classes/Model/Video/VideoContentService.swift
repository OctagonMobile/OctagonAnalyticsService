//
//  VideoContentService.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 03/08/2020.
//

import Foundation

public class VideoContentService {
    
    public var date: Date?
    public var entries: [VideoEntryService]   =   []
    
    init(_ responseModel: VideoContentResponse) {
        if let dateString = responseModel.keyAsString {
            date = dateString.formattedDate("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        }
        
        entries =   responseModel.aggsFields?.buckets.compactMap({ VideoEntryService($0) }) ?? []
    }
}

public class VideoEntryService {
    
    public var title: String       =   ""
    public var value: CGFloat      =   0.0

    init(_ responseModel: VideoEntryResponse) {
        title   =   responseModel.key ?? ""
        value   =   responseModel.value ?? 0.0
    }
}

//MARK: Private

class VideoDataAggregationResponse: Decodable, ParseJsonArrayProtocol {
    
    var bucketsList: [VideoContentResponse]    =   []
    private enum CodingKeys: String, CodingKey {
        case dateHistogramName
        enum NestedCodingKeys: String, CodingKey {
            case buckets
        }
    }

    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        let bucketsContainer = try container.nestedContainer(keyedBy: CodingKeys.NestedCodingKeys.self, forKey: .dateHistogramName)
        
        bucketsList = try bucketsContainer.decode([VideoContentResponse].self, forKey: .buckets)
    }
}

class VideoContentResponse: Decodable {
    
    var keyAsString: String?
    var key: Int?
    var docCount: Int?
    var aggsFields: VideoAggsFieldResponse?

    private enum CodingKeys: String, CodingKey {
        case key_as_string, key, doc_count, aggs_Fields
    }
    
    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.keyAsString    =   try? container.decode(String.self, forKey: .key_as_string)
        self.key            =   try? container.decode(Int.self, forKey: .key)
        self.docCount       =   try? container.decode(Int.self, forKey: .doc_count)
        self.aggsFields     =   try? container.decode(VideoAggsFieldResponse.self, forKey: .aggs_Fields)
    }
    
    func asUIModel() -> VideoContentService {
        return VideoContentService(self)
    }
}

class VideoAggsFieldResponse: Decodable, ParseJsonArrayProtocol {
    var buckets: [VideoEntryResponse]   =   []
    
    private enum CodingKeys: String, CodingKey {
        case buckets
    }
    
    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        buckets =   try container.decode([VideoEntryResponse].self, forKey: .buckets)
    }
}

class VideoEntryResponse: Decodable {
    
    var key: String?
    var docCount: Int?
    var value: CGFloat?
    
    private enum CodingKeys: String, CodingKey {
        case key, doc_count, max_field
        
        enum NestedCodingKeys: String, CodingKey {
            case value
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        
        self.key        =   try? container.decode(String.self, forKey: .key)
        self.docCount   =   try? container.decode(Int.self, forKey: .doc_count)
        
        let maxFieldContainer = try container.nestedContainer(keyedBy: CodingKeys.NestedCodingKeys.self, forKey: .max_field)
        self.value      =   try? maxFieldContainer.decode(CGFloat.self, forKey: .value)
    }
}

