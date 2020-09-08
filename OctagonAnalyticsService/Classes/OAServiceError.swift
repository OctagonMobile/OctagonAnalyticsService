//
//  OAServiceError.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 20/07/2020.
//

import Foundation

enum OAApiError: LocalizedError {
    case notfound
    case query
    case unknown(String)
}

extension OAApiError {
    var code: Int {
        switch self {
        case .notfound:
            return 404
        case .query:
            return 500
        case .unknown:
            return 1100
        }
    }
}

extension OAApiError {
    var appError: OAError {
        switch self {
        case .notfound:
            return OAError.notfound
        case .query:
            return OAError.query
        case .unknown(let desc):
            return OAError.unknown(desc)
        }
    }
}


public enum OAError: LocalizedError {
    case notfound
    case query
    case unknown(String)
}

extension OAError {
   public var code: Int {
        switch self {
        case .notfound:
            return 1001
        case .query:
            return 1002
        case .unknown:
            return 1100
        }
    }
}

extension OAError {
   public var errorDescription: String {
        switch self {
        case .notfound:
            return "Unable to Reach Server"
        case .query:
            return "Error With Request Query"
        case .unknown:
            return "Unknown Error Occured"
        }
    }
}

protocol OAErrorHandler {
    
}

extension OAErrorHandler {
    
    func parse(error: Error) -> OAError {
        let code = (error as NSError).code
        switch code {
        case OAApiError.notfound.code:
            return OAApiError.notfound.appError
        case OAApiError.query.code:
            return OAApiError.query.appError
        default:
            return OAApiError.unknown(error.localizedDescription).appError
        }
    }
    
    func parseResponseForError(_ apiResponse: [String: Any]?) -> OAError? {
        guard  let result = apiResponse else {
            return OAError.unknown("Unknown Error Occured")
        }
        let responseContent = (result["responses"] as? [[String: Any]])?.first
        
        if let code = responseContent?["status"] as? Int, code != 200 {
            let errorMessage = (responseContent?["error"] as? [String: Any])?["reason"] as? String ?? "Something went wrong!!!"
            switch code {
            case OAApiError.query.code:
                return OAError.query
            case OAApiError.notfound.code:
                return OAError.notfound
            default:
                return OAError.unknown(errorMessage)
            }
        }
        return nil
    }
}
