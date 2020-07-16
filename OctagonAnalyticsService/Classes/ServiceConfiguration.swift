//
//  ServiceConfiguration.swift
//  OctagonAnalyticsService
//
//  Created by Rameez on 16/07/2020.
//

import Foundation

public struct ServiceConfiguration {
    
    public var baseUrl: String
    
    public init(_ baseUrl: String) {
        self.baseUrl    =   baseUrl
    }
}
