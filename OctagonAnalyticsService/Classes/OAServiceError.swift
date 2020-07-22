//
//  OAServiceError.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 20/07/2020.
//

import Foundation

protocol OAServiceErrorProtocol: LocalizedError {
    var title: String? { get }
    var code: Int { get }
}

public struct OAServiceError: OAServiceErrorProtocol {
    var title: String?
    var code: Int
    public var errorDescription: String? { return _description }
    public var failureReason: String? { return _description }

    private var _description: String

    init(title: String? = nil, description: String, code: Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}
