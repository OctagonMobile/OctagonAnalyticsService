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
    case serviceUnavailable(String)
    case unknown(String)
}

extension OAApiError {
    var code: Int {
        switch self {
        case .notfound:
            return 404
        case .query:
            return 500
        case .serviceUnavailable:
            return 503
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
        case .serviceUnavailable(let desc):
            return OAError.serviceUnavailable(desc)
        case .unknown(let desc):
            return OAError.unknown(desc)
        }
    }
}


public enum OAError: LocalizedError {
    case notfound
    case query
    case serviceUnavailable(String)
    case unknown(String)
}

extension OAError {
   public var code: Int {
        switch self {
        case .notfound:
            return 1001
        case .query:
            return 1002
        case .serviceUnavailable:
            return 503
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
        case .serviceUnavailable(let desc):
            return desc
        case .unknown(let desc):
            return desc
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
            let errorDict = (responseContent?["error"] as? [String: Any])
            let rootCause = ((errorDict?["root_cause"] as? [[String: Any]])?.first)?["type"] as? String
            let errorMessage = rootCause ?? (errorDict?["reason"] as? String ?? "Something went wrong!!!")
            switch code {
            case OAApiError.query.code:
                return OAError.query
            case OAApiError.notfound.code:
                return OAError.notfound
            case OAApiError.serviceUnavailable("").code:
                return OAError.serviceUnavailable(errorMessage)
            default:
                return OAError.unknown(errorMessage)
            }
        }
        return nil
    }
}
